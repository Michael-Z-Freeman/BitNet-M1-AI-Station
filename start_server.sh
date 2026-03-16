#!/bin/bash
# Script to start llama-server with BitNet and Standard models
# Usage: ./start_server.sh [8b|2b|std-8b]

MODEL_TYPE=${1:-ii-search}

if [ "$MODEL_TYPE" == "ii-search" ]; then
    MODEL_PATH="models/ii-search/Intelligent-Internet.II-Search-4B.Q4_K_M.gguf"
    # Offload all layers to GPU (4B model fits easily)
    # Increase context window to 8k for search results
    EXTRA_FLAGS="-ngl 99 -c 8192"
    LLAMA_SERVER="/opt/homebrew/bin/llama-server"
    echo "Starting Intelligent-Internet 4B Search model (Full Metal, 8k Context)..."
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
    # Context limited to 2048 to prevent OOM
    EXTRA_FLAGS="-ngl 12 -c 2048"
    LLAMA_SERVER="/opt/homebrew/bin/llama-server"
    echo "Starting Standard Llama 3.1 8B Instruct (12 layers on GPU, 2k Context)..."
else
    echo "Unknown model type: $MODEL_TYPE. Use '8b', '2b', 'ii-search' or 'std-8b'."
    exit 1
fi

"$LLAMA_SERVER" \
    -m "$MODEL_PATH" \
    --host 0.0.0.0 \
    --port 8000 \
    $EXTRA_FLAGS
