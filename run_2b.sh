#!/bin/bash
# Script to run BitNet 2B model with Metal Acceleration
./bitnet-repo/build/bin/llama-cli \
  -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  -p "${1:-What is BitNet?}" \
  -n 128 \
  --temp 0
