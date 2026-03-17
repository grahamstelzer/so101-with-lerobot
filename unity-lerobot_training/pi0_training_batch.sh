#!/bin/bash
#SBATCH --job-name=pi0_training           # Job name
#SBATCH --partition=gpu                    # Partition (queue)
#SBATCH --gres=gpu:1
#SBATCH --constraint=a100-80g
#SBATCH --mem=32G                          # Memory
#SBATCH --time=10:00:00                    # Time limit hh:mm:ss
#SBATCH --output=logs/pi0_training_%j.out  # Standard output log
#SBATCH --error=logs/pi0_training_%j.err   # Standard error log
#SBATCH --mail-user=graham.stelzer.01@gmail.com
#SBATCH --mail-type=BEGIN


# debug things
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi -L
nvidia-smi




# Load modules
module load conda/latest

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate /work/pi_brian_flynn_uml_edu/graham_stelzer_student_uml_edu-conda/envs/lerobot/

# Set working directory
cd /work/pi_brian_flynn_uml_edu/

# Set Hugging Face cache paths
export HF_HOME=/work/pi_brian_flynn_uml_edu/hf_cache
export HF_DATASETS_CACHE=/work/pi_brian_flynn_uml_edu/hf_cache/datasets
export HF_HUB_CACHE=/datasets/ai/lerobot/hub
export TRANSFORMERS_CACHE=/datasets/ai/lerobot/hub

# Hugging Face authentication
# hf auth login --token $HF_HUB_TOKEN

# Run training
lerobot-train \
  --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
  --policy.type=pi0 \
  --output_dir=./outputs/pi0_training \
  --job_name=pi0_training \
  --policy.pretrained_path=lerobot/pi0_base \
  --policy.repo_id=grahamwichhh/v2_pi0_so101_lego-to-mug_50ep \
  --policy.compile_model=true \
  --policy.gradient_checkpointing=true \
  --policy.dtype=bfloat16 \
  --policy.freeze_vision_encoder=false \
  --policy.train_expert_only=false \
  --steps=3000 \
  --policy.device=cuda \
  --batch_size=16 \
  --wandb.enable=false \
