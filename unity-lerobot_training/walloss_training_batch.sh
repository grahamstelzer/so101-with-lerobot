#!/bin/bash
#SBATCH --job-name=walloss_training           # Job name
#SBATCH --partition=gpu                    # Partition (queue)
#SBATCH --gres=gpu:1
#SBATCH --constraint=a100-80g
#SBATCH --mem=32G                          # Memory
#SBATCH --time=10:00:00                    # Time limit hh:mm:ss
#SBATCH --output=logs/walloss_offline_type_and_localpath_bs4_%j.out  # Standard output log
#SBATCH --error=logs/walloss_offline_type_and_localpath_bs4_%j.err   # Standard error log
#SBATCH --mail-user=graham.stelzer.01@gmail.com
#SBATCH --mail-type=BEGIN


# Load modules
module load conda/latest

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate lerobot-walloss-py310

# Set working directory
cd /work/pi_brian_flynn_uml_edu/

echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi

pip show transformers | grep Version


# Set Hugging Face cache paths
export HF_HOME=/work/pi_brian_flynn_uml_edu/hf_cache
export HF_DATASETS_CACHE=/work/pi_brian_flynn_uml_edu/hf_cache/datasets # location of dataset to be trained
export HF_HUB_CACHE=/datasets/ai/x-square-robot/hub # location of model
export TRANSFORMERS_CACHE=/datasets/ai/x-square-robot/hub


# force offline to try and minimize bandwidth usage on compute nodes
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
export HF_DATASETS_OFFLINE=1




# Hugging Face authentication
# hf auth login --token $HF_HUB_TOKEN


# lerobot-train \
#     --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
#     --policy.type=wall_x \
#     --output_dir=./outputs/wallx_training \
#     --job_name=wallx_training \
#     --policy.pretrained_path=/datasets/ai/x-square-robot/hub/models--X-Square-Robot--wall-oss-flow/snapshots/a4003288001825b10771cbc4b10b9c2315e9b862 \
#     --policy.prediction_mode=diffusion \
#     --policy.attn_implementation=eager \
#     --steps=3000 \
#     --policy.device=cuda \
#     --batch_size=32 \
#     --policy.repo_id=grahamwichhh/v2_walloss_so101_lego-to-mug_50ep


# Run training
# offline, type=wall_x only, will use cached??
lerobot-train \
    --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
    --policy.type=wall_x \
    --policy.push_to_hub=false \
    --output_dir=./outputs/wallx_training \
    --job_name=wallx_training \
    --policy.pretrained_name_or_path=/datasets/ai/x-square-robot/hub/models--X-Square-Robot--wall-oss-flow/snapshots/a4003288001825b10771cbc4b10b9c2315e9b862 \
    --policy.prediction_mode=diffusion \
    --policy.attn_implementation=eager \
    --steps=3000 \
    --policy.device=cuda \
    --batch_size=4 \
    --policy.repo_id=grahamwichhh/v2_walloss_so101_lego-to-mug_50ep

