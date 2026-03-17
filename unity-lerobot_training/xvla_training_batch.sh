#!/bin/bash
#SBATCH --job-name=xvla_training           # Job name
#SBATCH --partition=gpu                    # Partition (queue)
#SBATCH --gres=gpu:1
#SBATCH --constraint=a100-80g
#SBATCH --mem=32G                          # Memory
#SBATCH --time=10:00:00                    # Time limit hh:mm:ss
#SBATCH --output=logs/xvla_%j.out  # Standard output log
#SBATCH --error=logs/xvla_%j.err   # Standard error log
#SBATCH --mail-user=graham.stelzer.01@gmail.com
#SBATCH --mail-type=BEGIN



# note about dependencies:
# hf docs for xvla_base say to just install lerobot[xvla] or something but this gives a tformers version error
# also tried using the lerobot docs https://huggingface.co/docs/lerobot/en/xvla:
#   pip install -e .[xvla]
#   pip install lerobot[xvla]

# found that tformers version should be 
# transformers<=4.51.3
# from within the xvla github: https://github.com/search?q=repo%3A2toinf%2FX-VLA%20transformers&type=code

# im not sure if this is a real issue or if i accidently installed a wrong tformers version and the pip
# command didnt downgrade...
# Check current transformers version


# Load modules
module load conda/latest

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate lerobot-xvla-py310

# debug things
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi

pip show transformers | grep Version

# Set working directory
cd /work/pi_brian_flynn_uml_edu/

# Set Hugging Face cache paths
export HF_HOME=/work/pi_brian_flynn_uml_edu/hf_cache
export HF_DATASETS_CACHE=/work/pi_brian_flynn_uml_edu/hf_cache/datasets # location of dataset to be trained
export HF_HUB_CACHE=/datasets/ai/lerobot/hub # location of model
export TRANSFORMERS_CACHE=/datasets/ai/lerobot/hub

# force offline to try and minimize bandwidth usage on compute nodes
# export HF_HUB_OFFLINE=1
# export TRANSFORMERS_OFFLINE=1
# export HF_DATASETS_OFFLINE=1




# Hugging Face authentication
# hf auth login --token $HF_HUB_TOKEN

# Run training
  lerobot-train \
  --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
  --output_dir=/work/pi_brian_flynn_uml_edu/outputs/xvla_training \
  --job_name=xvla_training \
  --policy.path=lerobot/xvla-base \
  --policy.repo_id=grahamwichhh/v2_xvla_so101_lego-to-mug_50ep \
  --policy.dtype=bfloat16 \
  --policy.action_mode=auto \
  --steps=20000 \
  --policy.device=cuda \
  --policy.freeze_vision_encoder=false \
  --policy.freeze_language_encoder=false \
  --policy.train_policy_transformer=true \
  --policy.train_soft_prompts=true \
  --rename_map='{"observation.images.camera1": "observation.images.image", "observation.images.camera2": "observation.images.image2", "observation.images.camera2": "observation.images.images3"}'

