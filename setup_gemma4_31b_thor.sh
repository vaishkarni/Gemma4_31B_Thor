#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting Gemma 4 setup on Jetson Thor..."

# -------------------------------
# Config
# -------------------------------
HF_CACHE_DIR="$HOME/.cache/huggingface"
WEBUI_DATA_DIR="$HOME/open-webui"

LLAMA_IMAGE="ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-thor"
WEBUI_IMAGE="ghcr.io/open-webui/open-webui:main"

LLAMA_CONTAINER_NAME="gemma4-server"
WEBUI_CONTAINER_NAME="open-webui"

# -------------------------------
# Create required directories
# -------------------------------
echo "📁 Creating required directories..."
mkdir -p "$HF_CACHE_DIR"
mkdir -p "$WEBUI_DATA_DIR"

# -------------------------------
# Cleanup old containers
# -------------------------------
echo "🧹 Cleaning up old containers..."

if [ "$(docker ps -aq -f name=$LLAMA_CONTAINER_NAME)" ]; then
    docker rm -f $LLAMA_CONTAINER_NAME
fi

if [ "$(docker ps -aq -f name=$WEBUI_CONTAINER_NAME)" ]; then
    docker rm -f $WEBUI_CONTAINER_NAME
fi

# -------------------------------
# Start Gemma 4 LLM server
# -------------------------------
echo "🧠 Starting Gemma 4 (llama.cpp server)..."

docker run -d \
    --name $LLAMA_CONTAINER_NAME \
    --runtime=nvidia \
    --network host \
    -v $HF_CACHE_DIR:/root/.cache/huggingface \
    $LLAMA_IMAGE \
    llama-server -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M

echo "✅ Gemma 4 server started"

# -------------------------------
# Start Open WebUI
# -------------------------------
echo "🌐 Starting Open WebUI..."

docker run -d \
    --name $WEBUI_CONTAINER_NAME \
    --network host \
    -v $WEBUI_DATA_DIR:/app/backend/data \
    -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
    -e PORT=3000 \
    $WEBUI_IMAGE

echo "✅ Open WebUI started"

# -------------------------------
# Final Output
# -------------------------------
echo ""
echo "🎉 Setup Complete!"
echo "--------------------------------------"
echo "🧠 Gemma 4 Server: running in background"
echo "🌐 Open WebUI:     http://localhost:3000"
echo ""
echo "📌 Notes:"
echo "- First run will take time (model download)"
echo "- Make sure NVIDIA runtime is properly installed"
echo "- Configure Open WebUI manually to point to llama.cpp if needed"
echo "--------------------------------------"
