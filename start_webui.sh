#!/bin/bash
# Script to start Open WebUI
export OPENAI_API_BASE_URL="http://localhost:8000/v1"
export OPENAI_API_KEY="unused"
export HOST="0.0.0.0"
export PORT="8080"

# --- Web Search Settings (SearXNG) ---
export ENABLE_RAG_WEB_SEARCH=True
export RAG_WEB_SEARCH_ENGINE="searxng"
export SEARXNG_QUERY_URL="http://localhost:8888/search?q=<query>"
export RAG_WEB_SEARCH_RESULT_COUNT=3
export RAG_WEB_SEARCH_CONCURRENT_REQUESTS=10

source .venv-webui/bin/activate
open-webui serve
