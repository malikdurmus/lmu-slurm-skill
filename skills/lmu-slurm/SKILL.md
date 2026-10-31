---
name: lmu-slurm
description: Run jobs on the LMU IfI CIP SLURM cluster (ificip). Use for sbatch, srun, squeue, choosing a partition, GPU jobs, Abaki access, job limits, suspended or failed jobs, and checkpointing on the LMU CIP cluster.
---

# SLURM on the LMU IfI CIP cluster

Everything here was inspected on 2026-10-31. Facts carry their source in [references/cluster-facts.md](references/cluster-facts.md). If a command behaves differently from this file, trust the cluster and follow [references/recheck.md](references/recheck.md).

## First: ask about Abaki access

Make this your first action when this skill loads, before any command or advice, whatever the request is. Call the `AskUserQuestion` tool once per conversation, and reuse the answer afterwards:

- Question: "Do you have permission to use the Abaki machines?"
- Header: "Abaki"
- Single choice, with these options:
  - "Yes": "I was granted Abaki access. Claude verifies it before using it."
  - "No": "Use the general partitions only."
  - "Not sure": "Treat as no access for now."

If `AskUserQuestion` isn't available, ask the same question in chat and wait for the answer.

- **No or not sure:** use only the general partitions. Abaki needs an approved application, so mention [how to apply](references/cluster-facts.md#abaki) if the job really needs it.
- **Yes:** run the check under [Abaki](#abaki). Use Abaki only if it passes.

## Before submitting

1. **Choose the partition** from the table. Always pass `-p`, because there is no default partition.
2. **Set `--time`.** Unlimited partitions have no default limit, and shorter jobs get higher priority.
3. **Validate without submitting:** `sbatch --test-only job.sbatch`.
4. **Show the user the job count and the command**, then submit.

The job is ready when `--test-only` prints a start time and every checkpoint and log path is in the home directory or `BIG`.

## Choosing a partition

| Need | Partition | Hardware |
|---|---|---|
| CUDA GPU, up to 8 GB VRAM | `NvidiaAll` | RTX 2060 SUPER, i9-9900, ~62 GB RAM |
| CPU only, with up to ~120 GB RAM, no interruption from local users | `Krater` | Ryzen 7 PRO 5750G, ~121 GB RAM |
| CPU only, up to ~60 GB RAM | `AMD` | i9-9900, ~62 GB RAM, Radeon RX 5500 |
| Larger NVIDIA GPU, large RAM, approved users only | `Abaki` | RTX A5000 24 GB, 128 or 512 GB RAM |

`AMD` and `Krater` have no usable CUDA GPU: on the sampled nodes `nvidia-smi` fails. `All` mixes all three general partitions, so use it only for CPU work.

## Abaki

Run this only after the user confirms permission:

```bash
sacctmgr -n -P show assoc user=$USER format=QOS
sbatch --test-only -p Abaki -q abaki -t 01:00:00 --wrap=hostname
```

- **Passes** if the QOS list includes `abaki` and `--test-only` prints a start time. Submit with both `-p Abaki -q abaki`.
- **`Invalid qos specification`:** the account has no active Abaki access, even if it had access before. Tell the user to ask their supervisor or the RBG, and offer a general partition meanwhile.

`--test-only -p Abaki` without `-q abaki` can print a start time for an account without access, so it proves nothing about permission.

Abaki limits: default 1 day, maximum 5 days. Check `scontrol show reservations` first, because the Abaki nodes have a recurring reservation and jobs that can't finish before it won't start.

## Flags

| Goal | Use | Result of the alternative (tested with `--test-only`) |
|---|---|---|
| Get a GPU | `-p NvidiaAll`; the job gets the whole node | `--gres=gpu:1`, `--gpus=1`: `Invalid generic resource` |
| Get memory | The whole node's RAM comes with it | `--mem=16G`: `Requested node configuration is not available` |
| Get CPUs | The whole node, 14 CPUs on general partitions | `-c 20`: rejected. `-c 8`: accepted, still allocates 14 |
| Pick a node type | `-p`, or `--nodelist` | SLURM features are not configured |

Every job takes at least one whole node, so split work into at most 15 concurrent jobs instead of asking for part of a node.

## Limits

- 15 running and 30 submitted jobs per user.
- Each array task counts as a submitted job: `--array=0-1000` fails with `AssocMaxSubmitJobLimit`. Throttle with `%`, for example `--array=0-11%4`.
- Before a large batch, count existing jobs with `squeue -u $USER -h | wc -l`, then submit no more than the remainder.
- Avoid heterogeneous jobs. The RBG strongly discourages them.

## Interruptions and checkpointing

Treat every job as interruptible, and write a checkpoint regularly. Make the script resume from the latest one.

- **Local logins:** a job on a CIP room machine is suspended while a local user is logged in, and SLURM starts no new jobs on machines with one. The docs list `Krater` and `Abaki` as free of local-use interruptions.
- **Reboots:** all machines reboot at least once per week, normally at the weekend. Plan for jobs to end at a reboot. Automatic requeue after a reboot is untested.
- **Wall-clock time:** `ST=S` in `squeue` means suspended. Whether suspended time counts toward `--time` is untested, so leave a margin.

Start from [templates/job.sbatch](templates/job.sbatch). `--test-only` accepts it after `<...>` placeholders are filled in.

## Storage

- Home is NFS with a quota of 150 GB soft and 200 GB hard. Check with `df .`.
- `BIG` has its own quota of the same size and no backup. Create it with `mkBIG`, because a folder made with `mkdir` doesn't get the separate quota. Never create directories called `BIG` or `FAST` by hand.
- `/tmp` is on each node's local disk and isn't visible from other nodes. It's faster than home, has no backup and may be cleared on reboot. Use a personal subfolder, copy results back before the job ends, and keep scripts and checkpoints on home or `BIG`.
- There's no `$SCRATCH`, `$WORK` or `module` command. Use a virtual environment under home.

## Monitoring and debugging

```bash
squeue -u $USER                      # state and reason
scontrol show job <id>               # full details of an active job
sacct -j <id> -X -o JobID,Partition,State,ExitCode,Elapsed,NodeList
sprio -u $USER                       # why a job is waiting
sshare -u $USER                      # fairshare usage
sinfo -p NvidiaAll -o '%P %t %D'     # free nodes
```

| Symptom | Cause | Action |
|---|---|---|
| `No partition specified` | No default partition | Add `-p` |
| `Exit code 127`, script not found | Script in `/tmp` on another machine | Move it to home |
| `Unable to create TMPDIR ... Setting TMPDIR to /tmp` | Login `TMPDIR` was copied to the node | Harmless, the job continues. Avoid `$TMPDIR` paths from the login shell |
| `nvidia-smi` fails in the job | Job isn't on `NvidiaAll` or `Abaki` | Change the partition |
| No log file appears | The log directory doesn't exist (general SLURM behaviour) | `mkdir -p slurm_logs` before `sbatch` |
| Job disappears | Unknown | Report the time and partition to rbg@ifi.lmu.de |

`sacct` has no memory figures and no stored batch scripts here, so keep scripts in git and log `nvidia-smi` and memory use from the job itself.

For facts, sources and untested items, see [references/cluster-facts.md](references/cluster-facts.md).
