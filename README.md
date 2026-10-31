# 🖥️ lmu-slurm-skill

**Give Claude Code a working knowledge of the LMU IfI CIP SLURM cluster, so your jobs run the first time.**

On this cluster, `--gres=gpu:1` and `--mem=16G` are rejected, and only some partitions showed a usable CUDA GPU. General SLURM advice gets this wrong. This plugin gives Claude the rules checked on the cluster itself, labelled by source.

> Unofficial project, not made or endorsed by the RBG or LMU.

## 🚀 Install

In Claude Code:

```text
/plugin marketplace add malikdurmus/lmu-slurm-skill
/plugin install lmu-slurm@lmu-slurm-skill
```

Or from a shell:

```bash
claude plugin marketplace add malikdurmus/lmu-slurm-skill
claude plugin install lmu-slurm@lmu-slurm-skill
```

The skill loads when you ask about SLURM on the cluster, or you can run `/lmu-slurm:lmu-slurm`.

## ✨ What you get

- **The right partition:** which one fits your GPU, RAM and CPU needs.
- **A working `sbatch` template:** passes `sbatch --test-only` once its placeholders are filled in.
- **Flags that work here:** what fails on this cluster, and what to use instead.
- **Abaki access check:** asks whether you have permission, then verifies it before using those machines.
- **Jobs that survive interruptions:** checkpointing for local logins and weekly reboots.
- **Limits and debugging:** staying within 15 running and 30 submitted jobs, and fixing common errors.

## 💬 Try asking

- "Write an sbatch script for an 8-hour GPU training job."
- "Why is my job still waiting in the queue?"
- "My job shows `ST=S`. What's happening?"
- "How do I run 100 jobs within the limits?"

## 🔍 What it runs

The plugin contains only instructions, a template and reference notes. It has no hooks, servers or background code, and sends your data nowhere. Claude may run SLURM commands such as `squeue` and `sbatch` on your account, using your normal Claude Code permissions.

## 📅 How current is this?

It reflects this cluster's config and the RBG docs as of **2026-10-31**, checked from one student account. Limits, partitions and hardware can change, and your access may differ. Hardware was sampled on one node per partition.

Facts are labelled by source in [cluster-facts.md](skills/lmu-slurm/references/cluster-facts.md), including what is inferred or untested. To check them again, follow [recheck.md](skills/lmu-slurm/references/recheck.md). The RBG's own pages take priority over this repo.

## 📁 Layout

```text
.claude-plugin/plugin.json       plugin manifest
.claude-plugin/marketplace.json  lets the repo install as a marketplace
skills/lmu-slurm/SKILL.md        main instructions
skills/lmu-slurm/references/     facts and re-check steps
skills/lmu-slurm/templates/      sbatch template
```

## 📄 License

[MIT](LICENSE)
