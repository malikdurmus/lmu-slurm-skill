#!/bin/bash
#SBATCH --partition=NvidiaAll
#SBATCH --job-name=<name>
#SBATCH --time=08:00:00
#SBATCH --output=slurm_logs/%j.out
#SBATCH --error=slurm_logs/%j.err

# Run `mkdir -p slurm_logs` before sbatch.
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

# Stop early if this node has no working NVIDIA GPU. Remove for CPU jobs.
nvidia-smi -L

source .venv/bin/activate

# -u keeps logs live. The program should save and resume its own checkpoints.
python -u <script.py> --resume <checkpoint-dir>
