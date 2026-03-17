#!/bin/bash
#SBATCH --job-name=groot_training           # Job name
#SBATCH --partition=gpu                    # Partition (queue)
#SBATCH --gres=gpu:1
#SBATCH --constraint=a100-80g
#SBATCH --mem=32G                          # Memory
#SBATCH --time=10:00:00                    # Time limit hh:mm:ss
#SBATCH --output=logs/groot_h%j.out  # Standard output log
#SBATCH --error=logs/groot_h%j.err   # Standard error log
#SBATCH --mail-user=graham.stelzer.01@gmail.com
#SBATCH --mail-type=BEGIN


# IMPORTANT:
# groot requires flash attention (https://huggingface.co/docs/lerobot/en/groot)
# this is recommended to use with cuda12.1 and requires nvcc or error
# below are pip commands from docs, just listing here in case useful
#   pip install "torch>=2.2.1,<2.8.0" "torchvision>=0.21.0,<0.23.0" # --index-url https://download.pytorch.org/whl/cu1XX
#   pip install ninja "packaging>=24.2,<26.0" # flash attention dependencies
#   pip install "flash-attn>=2.5.9,<3.0.0" --no-build-isolation
#   python -c "import flash_attn; print(f'Flash Attention {flash_attn.__version__} imported successfully')"



module load conda/latest
module load cuda/12.1 # needed for flash attn

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate lerobot-groot-py310 

cd /work/pi_brian_flynn_uml_edu/

# debug things
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi


pip show transformers | grep Version

# Set Hugging Face cache paths
export HF_HOME=/work/pi_brian_flynn_uml_edu/hf_cache
export HF_DATASETS_CACHE=/work/pi_brian_flynn_uml_edu/hf_cache/datasets # location of dataset to be trained
export HF_HUB_CACHE=/datasets/ai/nvidia/hub # location of model
export TRANSFORMERS_CACHE=/datasets/ai/nvidia/hub



# Hugging Face authentication
# hf auth login --token $HF_HUB_TOKEN

# Run training
# from https://huggingface.co/blog/nvidia/nvidia-isaac-gr00t-in-lerobot 
# NOTE: no policy.pretrained arg, setting policy type does enough?

# IMPORTANT: DO NOT SAVE CHECKPOINTS!!!


lerobot-train \
 --policy.type=groot \
 --policy.push_to_hub=false \
 --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
 --batch_size=32 \
 --steps=20000 \
 --save_checkpoint=true \
 --wandb.enable=false \
 --save_freq=10000 \
 --log_freq=2 \
 --policy.tune_diffusion_model=false \
 --output_dir=/work/pi_brian_flynn_uml_edu/outputs/groot_training



# below version i had saved but not sure where i got it from?
# lerobot-train \
#  --output_dir=/work/pi_brian_flynn_uml_edu/outputs/groot_training \
#  --policy.pretrained_path= \
#  --save_checkpoint=true \
#  --batch_size=64 \
#  --steps=40000 \
#  --eval_freq=0 \
#  --save_freq=5000 \
#  --log_freq=10 \
#  --policy.push_to_hub=true \
#  --policy.type=groot \
#  --policy.repo_id=grahamwichhh/groot_libero_10_64_40000 \
#  --policy.tune_diffusion_model=false \
#  --dataset.repo_id=grahamwichhh/eval_v2_so101_lego-to-mug_50ep \
#  --env.type=libero \
#  --env.task=libero_10 \
#  --wandb.enable=true \
#  --wandb.disable_artifact=true \
#  --job_name=my-groot-libero-10-finetune