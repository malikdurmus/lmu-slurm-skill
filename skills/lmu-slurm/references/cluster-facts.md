# Cluster facts (inspected 2026-10-31)

Source labels:

- **[config]** SLURM configuration or live query
- **[tested]** `sbatch --test-only`, which submits nothing
- **[job]** measured inside a real one-minute job, on one node
- **[docs]** RBG web pages, linked at the end
- **[inferred]** concluded from the above, not directly confirmed
- **[untested]** not checked

## Cluster

- SLURM 23.11.4, cluster `ificip`, controller `slurmmaster1`, student account `stud_ifi`. [config]
- `SelectType=select/linear`, `GresTypes=(null)`, node memory configured as 1 MB, no node features. [config]
- Open to institute students and faculty without registration. Ubuntu 24.04 with home directories over NFS. [docs]
- Python 3.12.3 on the sampled nodes. [job]

## Partitions

| Partition | Nodes | CPUs per node | Time limit [config] |
|---|---|---|---|
| `NvidiaAll` | 25 | 14 (`bauxit`: 10) | none, no default |
| `AMD` | 66 | 14 | none, no default |
| `Krater` | 40 | 14 | none, no default |
| `All` | 131 | mixed | none, no default |
| `Abaki` | 4 | 8 or 32 | default 1 day, max 5 days |

## Hardware

| Partition | Sampled node [job] | Docs group [docs] |
|---|---|---|
| `NvidiaAll` | i9-9900, 62 GiB RAM, RTX 2060 SUPER 8 GB, driver 580, 201 GB disk | Gesteine A: same 25 hostnames |
| `AMD` | i9-9900, 62 GiB RAM, Radeon RX 5500, `nvidia-smi` fails, 201 GB disk | Gesteine B: lists 72 hosts, SLURM has 66 |
| `Krater` | Ryzen 7 PRO 5750G, 121 GiB RAM, integrated Radeon, `nvidia-smi` fails, 905 GB disk | Krater: 128 GB RAM |
| `Abaki` | not sampled | RTX A5000 24 GB. 1N: 8 threads, 128 GB RAM, 1 TB NVMe. 2N: 32 threads, 512 GB RAM, 2 TB NVMe |

- One node was sampled per partition, and the rest are [inferred] to match their docs group.
- `abakus11-12` are [inferred] to be 1N and `abakus21-22` to be 2N, from their CPU counts of 8 and 32.
- `CUDA_VISIBLE_DEVICES` was unset inside the job. [job]
- `/tmp` is mode 1777 on local ext4, with write and delete working. `/var/tmp1`, `/scratch` and `/local` don't exist on the general nodes sampled. [job]

## Flag tests

All on `NvidiaAll` unless noted. [tested]

| Flags | Result |
|---|---|
| none, no `-t` | accepted, 14 CPUs |
| no `-p` | `No partition specified or system default partition` |
| `--gres=gpu:1`, `--gpus=1` | `Invalid generic resource (gres) specification` |
| `--mem=16G`, `-c 20` | `Requested node configuration is not available` |
| `-c 8` | accepted, still 14 CPUs |
| `-N2` | accepted, 28 CPUs |
| `--array=0-11%4` | accepted |
| `--array=0-1000` | `AssocMaxSubmitJobLimit` |
| `--array=0-1001` | `Invalid job array specification` (`MaxArraySize=1001`) |
| `-q abaki`, account without active access | `Invalid qos specification` |
| `-p Abaki -t 00:05:00`, account without active access | accepted by the test |
| `-p Abaki -t 5-00:00:00` and `6-00:00:00` | `Requested node configuration is not available` |

The 5-day rejection is [inferred] to come from the upcoming reservation on the Abaki nodes, since the docs allow 5 days. Retest it when no reservation is close.

## Abaki

- Partition has `AllowQos=abaki`, and jobs need `-q abaki`. [config, docs]
- Example from the docs: `srun -q abaki -p Abaki rechenjob.sh`. [docs]
- Applying: "we can accept only applications for master or bachelor thesis workload", sent by the supervisor with the student's CIP account, the reason, and the deadline. [docs: rechenjobs] The German SLURM page also names courses, publications and projects as good reasons, so the pages disagree. Ask the RBG. [docs: slurm_de]
- Jobs there are never suspended for local users. [docs]
- A granted QOS can stop working: one account that ran `abaki` jobs until 2026-09 got `Invalid qos specification` on 2026-10-31. The cause is unknown. [tested]
- Without active access, whether a real job submitted to `-p Abaki` under QOS `normal` runs is [untested], and these jobs aren't permitted.
- Abaki has `/var/tmp1`, and 2N also `/var/tmp2`, as fast local SSDs. [docs]

## Limits and priority

- 15 running and 30 submitted jobs per user, QOS `normal`. [config, docs]
- Multifactor priority, fairshare weight 10000, 14-day half-life, `PriorityFavorSmall=YES`. [config]
- Shorter jobs get higher priority. Priority is set per user. [docs]
- Higher priority can be requested from the RBG with a reason. One page says thesis, publication or official project with confirmation, another "only in cases of dire deadline" pressure explained by the advisor. [docs]
- `PreemptType=preempt/qos`, `PreemptMode=REQUEUE`, QOSes `normal`, `high`, `abaki`. [config] Whether `normal` jobs get preempted in practice is [untested].
- `sched/backfill`, so jobs with a realistic `--time` can start earlier. [config; effect is inferred]

## Interruptions

- "Slurm will start no jobs on machines with a logged in local user", and running jobs are suspended until that user logs out. [docs]
- `Krater` and `Abaki` are listed with "No interuption due to local usage". [docs]
- "All computer reboot at least once per week - normally at the weekend." [docs]
- Abaki runtime: "max. 5 Tage oder bis Rechnerreboot". [docs]

## Storage and rules

- Home: 150 GB soft, 200 GB hard, backed up when possible. Check with `df .`. `quota` isn't installed. [docs, config]
- `BIG`: created with `mkBIG`, separate 150/200 GB quota, no backup. More can be requested by email. [docs]
- `/tmp`: no backup, may be deleted on reboot. The docs give no cleanup schedule. [docs]
- File servers aren't built for long-running data-heavy work, so use local disks for that. [docs]
- More than 4 GB per day of traffic beyond the MWN needs RBG approval. [docs]
- The docs cover no GPU request syntax or Python environments, and say home can hold installed software and container images. [docs]
- Contact: rbg@ifi.lmu.de. [docs]

## Accounting

`JobAcctGatherType` is `jobacct_gather/none` in `slurm.conf` and `(null)` in `scontrol show config`. No job accounting plugin is active in either case, so expect no memory figures. [config; effect is inferred] There's no `job_script` accounting flag, so `sacct` can't return batch scripts. [config]

## Sources

- https://www.rz.ifi.lmu.de/infos/slurm_en.html
- https://www.rz.ifi.lmu.de/infos/slurm_de.html
- https://www.rz.ifi.lmu.de/infos/compute_en.html
- https://www.rz.ifi.lmu.de/infos/rechenjobs_en.html
- https://www.rz.ifi.lmu.de/infos/eigene-dateien_en.html
- https://www.rz.ifi.lmu.de/infos/rbg_en.html
