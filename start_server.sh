#!/bin/bash
# Script to start llama-server with BitNet and Standard models
# Usage: ./start_server.sh [8b|2b|std-8b]

MODEL_TYPE=${1:-qwen-3b}

if [ "$MODEL_TYPE" == "qwen-3b" ]; then
    MODEL_PATH="models/qwen2.5-3b/qwen2.5-3b-instruct-q4_k_m.gguf"
    # Offload all layers to GPU (3B model is extremely light)
    # 24k context is the stable limit for 8GB RAM systems
    EXTRA_FLAGS="-ngl 99 -c 24576"
    LLAMA_SERVER="/opt/homebrew/bin/llama-server"
    echo "Starting Qwen2.5 3B Instruct model (Full Metal, 24k Context)..."
elif [ "$MODEL_TYPE" == "ii-search" ]; then
    MODEL_PATH="models/ii-search/Intelligent-Internet.II-Search-4B.Q4_K_M.gguf"
    # Offload all layers to GPU (4B model fits easily)
    # 16k context is the "sweet spot" for 8GB RAM systems
    EXTRA_FLAGS="-ngl 99 -c 16384"
    LLAMA_SERVER="/opt/homebrew/bin/llama-server"
    echo "Starting Intelligent-Internet 4B Search model (Full Metal, 16k Context)..."
elif [ "$MODEL_TYPE" == "8b" ]; then
    MODEL_PATH="models/Llama3-8B-1.58/Llama3-8B-1.58-100B-tokens-TQ2_0.gguf"
    EXTRA_FLAGS="-ngl 0"
    LLAMA_SERVER="./bitnet-repo/build/bin/llama-server"
    echo "Starting 8B BitNet model on CPU..."
elif [ "$MODEL_TYPE" == "2b" ]; then
    MODEL_PATH="models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf"
    EXTRA_FLAGS=""
    LLAMA_SERVER="./bitnet-repo/build/bin/llama-server"
    echo "Starting 2B BitNet model with Metal..."
elif [ "$MODEL_TYPE" == "std-8b" ]; then
    MODEL_PATH="models/Llama-3.1-8B-Instruct/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
    # Offload 12/33 layers to GPU to stay within 8GB RAM limits
    # Increase context to 8k for search results
    EXTRA_FLAGS="-ngl 12 -c 8192"
    LLAMA_SERVER="/opt/homebrew/bin/llama-server"
    echo "Starting Standard Llama 3.1 8B Instruct (12 layers on GPU, 8k Context)..."
else
    echo "Unknown model type: $MODEL_TYPE. Use '8b', '2b', 'ii-search' or 'std-8b'."
    exit 1
fi

"$LLAMA_SERVER" \
    -m "$MODEL_PATH" \
    --host 0.0.0.0 \
    --port 8000 \
    $EXTRA_FLAGS
