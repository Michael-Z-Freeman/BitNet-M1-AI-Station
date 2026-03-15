#!/bin/bash
# Script to start Open WebUI
export OPENAI_API_BASE_URL="http://localhost:8000/v1"
export OPENAI_API_KEY="unused"
export HOST="0.0.0.0"
export PORT="8080"

source .venv-webui/bin/activate
open-webui serve
