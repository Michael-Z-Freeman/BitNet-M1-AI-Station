#!/bin/bash
# Master script to start services
# This script is called by the macOS LaunchAgents

# Navigate to the project directory
cd /Users/michaelzfreeman/Installations/BitNet

# Clean up any existing background logs if they exist
touch webui.log

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"

# Kill any existing instances to avoid port conflicts
pkill -f llama-server
pkill -f open-webui
pkill -f webapp.py

# Clean up logs
rm -f /Users/michaelzfreeman/Installations/BitNet/server.log
rm -f /Users/michaelzfreeman/Installations/BitNet/webui.log
rm -f /Users/michaelzfreeman/Installations/BitNet/searxng.log

# 1. Start the Model Server (Qwen2.5 3B Instruct)
# Fast, stable on 8GB RAM, supports search, NO "thinking" overhead
./start_server.sh > /Users/michaelzfreeman/Installations/BitNet/server.log 2>&1 &

# 2. Start SearXNG
./start_searxng.sh > /Users/michaelzfreeman/Installations/BitNet/searxng.log 2>&1 &

# Wait for services to initialize
sleep 15

# 3. Start WebUI in the FOREGROUND (so launchd keeps the script alive)
./start_webui.sh > /Users/michaelzfreeman/Installations/BitNet/webui.log 2>&1
