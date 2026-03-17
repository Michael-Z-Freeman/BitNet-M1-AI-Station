# AI Search Station

This project provides a high-performance, private AI search station (Perplexity-style) and inference server. Originally optimized for an 8GB M1 Mac, it is now being migrated to a 16GB Linux machine with an AMD GPU (ROCm).

## 🐧 Linux Migration & Setup (AMD GPU / ROCm)

When moving this project to a Linux machine with an AMD GPU, follow these steps to ensure the new Gemini CLI agent understands the architecture.

### 1. System Dependencies (Apt)
The new machine needs core build tools and Python development headers for SearXNG and llama.cpp.
```bash
sudo apt update
sudo apt install -y build-essential cmake git python3-pip python3-dev libxml2-dev libxslt-dev zlib1g-dev
```

### 2. Install llama.cpp with ROCm Support
Unlike the Mac version which uses Homebrew, the Linux version must be compiled from source to enable the AMD GPU (ROCm/HIP).
```bash
git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
mkdir build && cd build
# Replace /opt/rocm with your actual ROCm path if different
CC=/opt/rocm/bin/hipcc CXX=/opt/rocm/bin/hipcc cmake .. -DGGML_HIPBLAS=ON
cmake --build . --config Release --parallel 8
```
*The resulting binary `llama-server` should be used in `start_server.sh`.*

### 3. Recreate Python Environments
Use `uv` to recreate the isolated environments for SearXNG and Open WebUI.
```bash
# SearXNG
uv venv .venv-searxng --python 3.12
source .venv-searxng/bin/activate
uv pip install -r searxng_repo/requirements.txt

# Open WebUI
uv venv .venv-webui --python 3.12
source .venv-webui/bin/activate
uv pip install open-webui
```

### 4. Linux Automation (Systemd)
Replace the macOS `.plist` with a standard `systemd` service file located at `/etc/systemd/system/ai-station.service`.
```ini
[Unit]
Description=AI Search Station Master Script
After=network.target

[Service]
Type=simple
User=[YOUR-USERNAME]
WorkingDirectory=/path/to/BitNet
ExecStart=/bin/bash /path/to/BitNet/launch_ai_station.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

### 5. Hardware Optimization (16GB RAM)
On the 16GB Linux machine, you can increase the context window and search depth significantly:
- **Qwen 3B:** Increase context to **64k** (`-c 65536`).
- **Search Results:** Increase `WEB_SEARCH_RESULT_COUNT` to **10** in `start_webui.sh`.

---

## 🚀 Quick Start (Original macOS)

### 1. Start the System
You can start all components individually or use the automation script.

**Option A: Individual Start (3 Terminals)**
```bash
# Terminal 1: Model Server (Qwen2.5 3B Instruct - DEFAULT)
./start_server.sh

# Terminal 2: Local Search Engine (SearXNG)
./start_searxng.sh

# Terminal 3: Web Interface (Open WebUI)
./start_webui.sh
```

**Option B: Master Script**
```bash
./launch_ai_station.sh
```

### 2. Access the AI
Open your browser to:
- **Local:** `http://localhost:8080`
- **LAN:** `http://[YOUR-MAC-IP]:8080`

---

## 🔍 AI Search Engine (SearXNG)

This setup uses a local, Docker-free installation of **SearXNG** to provide live internet access to the AI.

- **URL:** `http://localhost:8888`
- **Privacy:** 100% local and private; no search engine accounts or API keys required.
- **Integration:** Open WebUI is pre-configured to use SearXNG for RAG (Retrieval-Augmented Generation).

---

## 🤖 Automation (macOS LaunchAgents)

The system is configured to start automatically on login using macOS `launchd`.

### Installation
1. Move the configuration file:
   ```bash
   cp com.ai.station.startup.plist ~/Library/LaunchAgents/
   ```
2. Load the service:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.ai.station.startup.plist
   ```

### Management
- **Stop Automation:** `launchctl unload ~/Library/LaunchAgents/com.ai.station.startup.plist`
- **Force Kill All Processes:** `pkill -f llama-server && pkill -f open-webui && pkill -f webapp.py`
- **Check Status:** `launchctl list | grep com.ai.station.startup`

---

## ⚙️ Optimization for 8GB RAM

### 1. Qwen2.5 3B Instruct (Default)
- **Model:** `Qwen2.5-3B-Instruct` (Q4_K_M GGUF)
- **Memory Footprint:** ~2.1GB.
- **Context Window:** **24576 tokens** (Stable and spacious for search-augmented chats).
- **GPU Offloading:** **100% layers** offloaded to Metal for high-speed inference.

### 2. II-Search 4B Model (Option: `ii-search`)
- **Model:** `Intelligent-Internet.II-Search-4B` (Q4_K_M GGUF)
- **Memory Footprint:** ~2.7GB.
- **Context Window:** **24576 tokens** (Reasoning model, slow but deep).
- **GPU Offloading:** **100% layers** offloaded to Metal.

### 2. Llama 3.1 8B (Option: `std-8b`)
- **Memory Footprint:** ~4.9GB.
- **Context Window:** Restricted to **2048 tokens** to prevent OOM.
- **GPU Offloading:** Only **12 of 33 layers** offloaded to stay within unified memory limits.

---

## 🛠 Project Structure

- `models/qwen2.5-3b/`: The default 3B AI search model.
- `models/ii-search/`: The 4B AI reasoning search model.
- `searxng_repo/`: SearXNG source code.
- `searxng/settings.yml`: Local configuration for the search engine.
- `.venv-searxng/`: Python 3.12 environment for SearXNG.
- `.venv-webui/`: Python 3.12 environment for Open WebUI.
- `.venv/`: Python 3.9 environment for BitNet models.

## 🏗 Setup & Maintenance

### Dependencies
- **Homebrew llama.cpp:** Required for the latest Qwen3-based search models.
  ```bash
  brew install llama.cpp
  ```

### Manual SearXNG Setup
If you need to recreate the search engine environment:
```bash
uv venv .venv-searxng --python 3.12
source .venv-searxng/bin/activate
uv pip install -r searxng_repo/requirements.txt
```

### Logs
- **Search Engine:** `searxng.log`
- **Model Server:** `server.log`
- **Web UI:** `webui.log`
- **Startup:** `launchd_stderr.log`
