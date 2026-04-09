#!/bin/bash

set -e

echo "🚀 Jetson Thor Gemma 4 Setup Starting..."

# -------------------------------
# CONFIG
# -------------------------------
HF_CACHE_DIR="$HOME/.cache/huggingface"
WEBUI_DATA_DIR="$HOME/open-webui"

LLAMA_IMAGE="ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-thor"
WEBUI_IMAGE="ghcr.io/open-webui/open-webui:main"

LLAMA_CONTAINER="gemma4-server"
WEBUI_CONTAINER="open-webui"

# -------------------------------
# CHECK DOCKER
# -------------------------------
if ! command -v docker &> /dev/null
then
    echo "🐳 Docker not found. Installing..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER

    echo "⚠️ Docker installed. Please logout/login and rerun the script."
    exit 1
fi

# -------------------------------
# CHECK NVIDIA RUNTIME
# -------------------------------
if ! docker info | grep -q "nvidia"; then
    echo "⚠️ NVIDIA runtime not detected!"
    echo "Make sure Jetson is properly configured with NVIDIA Container Runtime."
fi

# -------------------------------
# SYSTEM INFO (DEBUG FRIENDLY)
# -------------------------------
echo "📊 System Info:"
free -h || true

# -------------------------------
# CREATE DIRECTORIES
# -------------------------------
echo "📁 Preparing directories..."
mkdir -p "$HF_CACHE_DIR"
mkdir -p "$WEBUI_DATA_DIR"

# -------------------------------
# CLEANUP OLD CONTAINERS
# -------------------------------
echo "🧹 Cleaning old containers..."
docker rm -f $LLAMA_CONTAINER 2>/dev/null || true
docker rm -f $WEBUI_CONTAINER 2>/dev/null || true

# -------------------------------
# START LLAMA SERVER
# -------------------------------
echo "🧠 Starting Gemma 4 server..."

docker run -d \
    --name $LLAMA_CONTAINER \
    --runtime=nvidia \
    --network host \
    -v $HF_CACHE_DIR:/root/.cache/huggingface \
    $LLAMA_IMAGE \
    llama-server -hf ggml-org/gemma-4-31B-it-GGUF:Q4_K_M

# -------------------------------
# WAIT FOR MODEL SERVER (REAL CHECK)
# -------------------------------
echo "⏳ Waiting for model API..."

for i in {1..60}; do
    if curl -s http://127.0.0.1:8080/v1/models | grep -q "data"; then
        echo "✅ Model API is ready!"
        break
    fi
    sleep 2
done

# -------------------------------
# START OPEN WEBUI (AUTO CONFIG)
# -------------------------------
echo "🌐 Starting Open WebUI..."

docker run -d \
    --name $WEBUI_CONTAINER \
    --network host \
    -v $WEBUI_DATA_DIR:/app/backend/data \
    -e PORT=3000 \
    -e OPENAI_API_BASE_URL=http://127.0.0.1:8080/v1 \
    -e OPENAI_API_KEY=none \
    $WEBUI_IMAGE

# -------------------------------
# FINAL OUTPUT
# -------------------------------
echo ""
echo "🎉 Setup Complete!"
echo "----------------------------------------"
echo "🌐 Open WebUI: http://localhost:3000"
echo "🧠 Gemma 4 API: http://127.0.0.1:8080/v1"
echo ""
echo "💡 If model doesn't show:"
echo "   Go to Settings → Connections → Add OpenAI endpoint"
echo "   URL: http://127.0.0.1:8080/v1"
echo "----------------------------------------"

# -------------------------------
# OPTIONAL: ATTACH LOGS
# -------------------------------
if [ "$1" == "--attach" ]; then
    echo "📜 Attaching logs..."
    docker logs -f $LLAMA_CONTAINER
fi
