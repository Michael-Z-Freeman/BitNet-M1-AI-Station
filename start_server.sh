#!/bin/bash
# Script to start llama-server with BitNet and Standard models
# Usage: ./start_server.sh [8b|2b|std-8b]

MODEL_TYPE=${1:-qwen-3b}
LLAMA_SERVER_PATH="$(pwd)/llama.cpp/build/bin/llama-server"

# --- ROCm / AMD GPU Environment Variables (Ubuntu paths) ---
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
export HIP_VISIBLE_DEVICES=0
export GGML_HIPBLAS=1
export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=8"

if [ "$MODEL_TYPE" == "qwen-3b" ]; then
    MODEL_PATH="models/qwen2.5-3b/qwen2.5-3b-instruct-q4_k_m.gguf"
    # Offload all layers to GPU
    # 64k context for 16GB RAM systems
    EXTRA_FLAGS="-ngl 99 -c 65536"
    echo "Starting Qwen2.5 3B Instruct model (AMD GPU, 64k Context)..."
elif [ "$MODEL_TYPE" == "ii-search" ]; then
    MODEL_PATH="models/ii-search/Intelligent-Internet.II-Search-4B.Q4_K_M.gguf"
    # Offload all layers to GPU (4B model fits easily)
    # 32k context for 16GB RAM systems
    EXTRA_FLAGS="-ngl 99 -c 32768"
    echo "Starting Intelligent-Internet 4B Search model (AMD GPU, 32k Context)..."
elif [ "$MODEL_TYPE" == "8b" ]; then
    MODEL_PATH="models/Llama3-8B-1.58/Llama3-8B-1.58-100B-tokens-TQ2_0.gguf"
    EXTRA_FLAGS="-ngl 99 -c 8192"
    echo "Starting 8B BitNet model (AMD GPU, 8k Context)..."
elif [ "$MODEL_TYPE" == "2b" ]; then
    MODEL_PATH="models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf"
    EXTRA_FLAGS="-ngl 99 -c 16384"
    echo "Starting 2B BitNet model (AMD GPU, 16k Context)..."
elif [ "$MODEL_TYPE" == "std-8b" ]; then
    MODEL_PATH="models/Llama-3.1-8B-Instruct/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
    # Offload all layers to GPU (8B fits in 16GB VRAM/RAM)
    EXTRA_FLAGS="-ngl 99 -c 16384"
    echo "Starting Standard Llama 3.1 8B Instruct (AMD GPU, 16k Context)..."
else
    echo "Unknown model type: $MODEL_TYPE. Use 'qwen-3b', '8b', '2b', 'ii-search' or 'std-8b'."
    exit 1
fi

"$LLAMA_SERVER_PATH" \
    -m "$MODEL_PATH" \
    --host 0.0.0.0 \
    --port 8000 \
    $EXTRA_FLAGS
