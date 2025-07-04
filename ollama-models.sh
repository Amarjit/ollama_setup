#!/bin/bash

# Configurable VRAM limit
AVAILABLE_VRAM=8  # Set this to your actual GPU VRAM

# Step 1: Check & Install Ollama (Windows - Git Bash/WSL assumed)
if ! command -v ollama &> /dev/null; then
  echo "🚀 Ollama not found. Installing..."

  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo "➡️  Please manually install Ollama from: https://ollama.com/download"
    exit 1
  else
    curl -fsSL https://ollama.com/install.sh | sh
  fi
else
  echo "✅ Ollama is already installed."
  echo "🔄 Checking for updates..."
  ollama update
fi

# Step 2: Define models and requirements
declare -A models=(
  [llama3]="General chat + reasoning"
  [llama3.3]="Updated LLaMA 3 | Better reasoning"
  [llama4:scout]="Advanced translation + reasoning"
  [gemma3]="General + coding"
  [codellama:13b-instruct]="Coding model | 13B"
  [codellama:34b-instruct]="High-end coding model | 34B"
  [deepseek-coder:33b-instruct]="Large coding expert | 33B"
  [mistral]="Fast & efficient general model"
  [phi3]="Lightweight LLM"
  [llava]="Vision + language | 📷 Image support"
  [bakllava]="Light multimodal (image+text) | 📷 Image support"
  [llava-phi3]="Smallest image+text model | 📷 Image support"
  [dolphin-mixtral]="Advanced reasoning/chat | Mixture of Experts"
)

declare -A model_vram_reqs=(
  [llama3]=8
  [llama3.3]=10
  [llama4:scout]=16
  [gemma3]=6
  [codellama:13b-instruct]=8
  [codellama:34b-instruct]=24
  [deepseek-coder:33b-instruct]=24
  [mistral]=6
  [phi3]=4
  [llava]=12
  [bakllava]=8
  [llava-phi3]=8
  [dolphin-mixtral]=24
)

echo -e "\n📦 Checking installed models..."
installed=$(ollama list | awk '{print $1}' | tail -n +2)

echo -e "\n🧠 Pulling models for VRAM: ${AVAILABLE_VRAM} GB\n"

for model in "${!models[@]}"; do
  desc="${models[$model]}"
  req="${model_vram_reqs[$model]}"
  
  if [[ "$installed" =~ (^|[[:space:]])"$model"($|[[:space:]]) ]]; then
    echo "✅ $model already installed — $desc (Needs ${req}GB VRAM)"
  else
    if (( AVAILABLE_VRAM >= req )); then
      echo "⬇️  Pulling $model — $desc (Needs ${req}GB VRAM)"
      ollama pull "$model"
    else
      echo "⚠️  Skipping $model — Needs ${req}GB VRAM (You have ${AVAILABLE_VRAM}GB)"
    fi
  fi
done

echo -e "\n🎉 Done. All compatible models are ready!"
