# Re-checking the cluster

Run this when a command behaves differently from the skill, or when the inspection date is old. Sections 1 and 2 submit nothing.

## 1. Configuration

```bash
sinfo -o '%P %a %D %c %l'
scontrol show partition
scontrol show config | grep -iE 'SelectType|GresTypes|MaxArraySize|PriorityType|PriorityWeightFairshare|PriorityFavorSmall|PreemptMode|PreemptType|JobAcctGatherType'
sacctmgr -n -P show assoc user=$USER format=Account,QOS,MaxJobs,MaxSubmit
scontrol show reservations
```

## 2. Flags

```bash
t() { echo "== $*"; sbatch --test-only "$@" --wrap=hostname 2>&1; }
t -p NvidiaAll -t 00:05:00
t -p NvidiaAll -t 00:05:00 --gres=gpu:1
t -p NvidiaAll -t 00:05:00 --gpus=1
t -p NvidiaAll -t 00:05:00 --mem=16G
t -p NvidiaAll -t 00:05:00 -c 20
t -p NvidiaAll -t 00:05:00 --array=0-11%4
t -p Abaki -q abaki -t 01:00:00
```

## 3. Hardware

This submits a real one-minute job, so ask the user first. Replace `<partition>`:

```bash
srun -p <partition> -N1 -t 00:01:00 --immediate=30 bash -c 'hostname; lscpu | grep -m1 "Model name"; free -h; nvidia-smi --query-gpu=name,memory.total --format=csv,noheader; df -h /tmp'
```

Pass commands inline as shown, because a script in the login machine's `/tmp` doesn't exist on the node.

## 4. Docs

Read the pages listed under Sources in [cluster-facts.md](cluster-facts.md).

Update `cluster-facts.md` and the inspection date when anything differs, and update `SKILL.md` if the change affects a rule there. Keep usernames, including those in reservation output, out of the repo.
