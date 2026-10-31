# lmu-slurm-skill

A Claude Code plugin for running SLURM jobs on the LMU IfI CIP cluster. It covers choosing a partition, a working `sbatch` template, which flags fail here, Abaki access, job limits, suspension and checkpointing, debugging, and re-checking the config.

This is an unofficial project, not made or endorsed by the RBG or LMU.

## Install

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

## How current is this?

It reflects this cluster's config and the RBG docs as of **2026-10-31**, checked from one student account. Limits, partitions and hardware can change, and your access may differ. Hardware was sampled on one node per partition.

Facts are labelled by source in [cluster-facts.md](skills/lmu-slurm/references/cluster-facts.md), including what is inferred or untested. To check them again, follow [recheck.md](skills/lmu-slurm/references/recheck.md). The RBG's own pages take priority over this repo.

## Layout

```text
.claude-plugin/plugin.json       plugin manifest
.claude-plugin/marketplace.json  lets the repo install as a marketplace
skills/lmu-slurm/SKILL.md        main instructions
skills/lmu-slurm/references/     facts and re-check steps
skills/lmu-slurm/templates/      sbatch template
```

## License

[MIT](LICENSE)
