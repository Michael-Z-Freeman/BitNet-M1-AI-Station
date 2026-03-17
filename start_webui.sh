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

# Note: For best results, go to 'Workspace > Models > Edit Qwen2.5 3B' 
# and set the System Prompt to: 
# "You are a helpful AI assistant. Use ONLY the provided search results to answer questions. 
# If the information is not in the results, state that you cannot find it. 
# Do not use internal knowledge for current events or dates."

source .venv-webui/bin/activate
open-webui serve
