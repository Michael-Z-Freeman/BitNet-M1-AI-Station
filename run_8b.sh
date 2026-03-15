#!/bin/bash
# Script to run Llama3 8B 1.58-bit model on CPU
./bitnet-repo/build/bin/llama-cli \
  -m models/Llama3-8B-1.58/Llama3-8B-1.58-100B-tokens-TQ2_0.gguf \
  -p "${1:-The meaning of life is}" \
  -n 128 \
  --temp 0 \
  -ngl 0
