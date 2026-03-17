#!/bin/bash
# Script to start Open WebUI
export OPENAI_API_BASE_URL="http://localhost:11434/v1"
export OPENAI_API_KEY="unused"
export HOST="0.0.0.0"
export PORT="8080"

# --- Web Search Settings (Serper.dev) ---
export ENABLE_WEB_SEARCH=True
export WEB_SEARCH_ENGINE="serper"
export SERPER_API_KEY="30a4111b2be4df9eaf745d1bea26cfb66e86d559"
export WEB_SEARCH_RESULT_COUNT=10
export WEB_SEARCH_CONCURRENT_REQUESTS=10

# --- RAG / Context Settings ---
export RAG_TOP_K=10
export RAG_RELEVANCE_THRESHOLD=0.0
export ENABLE_RAG_HYBRID_SEARCH=True

# Note: For best results, go to 'Workspace > Models > Edit Qwen2.5 3B' 
# and set the System Prompt to: 
# "You are a comprehensive AI search assistant. Use the provided search results to give a detailed, 
# structured, and well-reasoned answer. Cite your sources using the [Source Name] format. 
# Synthesize information from multiple results to provide a complete overview. 
# If results are insufficient, state what is missing."

source .venv-webui/bin/activate
open-webui serve
