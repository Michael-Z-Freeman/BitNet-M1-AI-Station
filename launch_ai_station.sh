#!/bin/bash
# Master script to start services
# This script is called by the macOS LaunchAgents

# Navigate to the project directory
cd /home/michaelzfreeman/Installations/BitNet-M1-AI-Station

# Clean up any existing background logs if they exist
touch webui.log

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"

# Kill any existing instances to avoid port conflicts
pkill -f llama-server
pkill -f open-webui
pkill -f webapp.py

# Clean up logs
rm -f /home/michaelzfreeman/Installations/BitNet-M1-AI-Station/server.log
rm -f /home/michaelzfreeman/Installations/BitNet-M1-AI-Station/webui.log
rm -f /home/michaelzfreeman/Installations/BitNet-M1-AI-Station/searxng.log

# 1. Start the Model Server (Now using Ollama, which is already running as a system service)
# No need to start llama-server manually anymore.

# 2. Wait for services to initialize
sleep 5

# 3. Start WebUI in the FOREGROUND
./start_webui.sh > /home/michaelzfreeman/Installations/BitNet-M1-AI-Station/webui.log 2>&1
