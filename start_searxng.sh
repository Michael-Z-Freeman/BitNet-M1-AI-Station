#!/bin/bash
# Script to start SearXNG locally on macOS without Docker

# Path to the SearXNG source code
SEARXNG_REPO_PATH="$(pwd)/searxng_repo"
# Path to the custom settings file
SEARXNG_SETTINGS_PATH="$(pwd)/searxng/settings.yml"
# Path to the virtual environment
VENV_PATH="$(pwd)/.venv-searxng"

# Load local secrets if they exist
if [ -f .env ]; then
    source .env
fi

if [ ! -d "$VENV_PATH" ]; then
    echo "Virtual environment not found. Please ensure it is set up correctly."
    exit 1
fi

export PYTHONPATH="$SEARXNG_REPO_PATH:$PYTHONPATH"
export SEARXNG_SETTINGS_PATH="$SEARXNG_SETTINGS_PATH"

echo "Starting SearXNG on http://localhost:8888..."
source "$VENV_PATH/bin/activate"
python3 "$SEARXNG_REPO_PATH/searx/webapp.py"
