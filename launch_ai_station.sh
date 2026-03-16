#!/bin/bash
# Master script to start services
# This script is called by the macOS LaunchAgents

# Navigate to the project directory
cd /Users/michaelzfreeman/Installations/BitNet

# Clean up any existing background logs if they exist
touch webui.log

# 1. Start the Model Server (Standard 8B)
# We don't background here, we let the script wait or manage it
# But we need both to run, so we'll use a specific approach for launchd
# Use absolute paths for everything to be safe

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"

# Kill any existing instances to avoid port conflicts
pkill -f llama-server
pkill -f open-webui
pkill -f webapp.py

# Clean up logs
rm -f /Users/michaelzfreeman/Installations/BitNet/server.log
rm -f /Users/michaelzfreeman/Installations/BitNet/webui.log
rm -f /Users/michaelzfreeman/Installations/BitNet/searxng.log

# 1. Start the Model Server (Intelligent-Internet 4B Search)
# Uses ii-search by default as configured in start_server.sh
./start_server.sh > /Users/michaelzfreeman/Installations/BitNet/server.log 2>&1 &

# 2. Start SearXNG
./start_searxng.sh > /Users/michaelzfreeman/Installations/BitNet/searxng.log 2>&1 &

# Wait for services to initialize
sleep 15

# 3. Start WebUI in the FOREGROUND (so launchd keeps the script alive)
./start_webui.sh > /Users/michaelzfreeman/Installations/BitNet/webui.log 2>&1
