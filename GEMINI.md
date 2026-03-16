# AI Search Station (8GB M1 Mac)

This project provides a high-performance, private AI search station (Perplexity-style) and inference server running on Apple Silicon. It combines specialized search models, a local search engine (SearXNG), and Open WebUI, all optimized for an 8GB RAM footprint.

## 🚀 Quick Start

### 1. Start the System
You can start all components individually or use the automation script.

**Option A: Individual Start (3 Terminals)**
```bash
# Terminal 1: Model Server (Intelligent-Internet 4B Search - DEFAULT)
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

### 1. II-Search 4B Model (Default)
- **Model:** `Intelligent-Internet.II-Search-4B` (Q4_K_M GGUF)
- **Memory Footprint:** ~2.7GB.
- **Context Window:** **8192 tokens** (Optimized for reading multiple search results).
- **GPU Offloading:** **100% layers** offloaded to Metal for high-speed inference.

### 2. Llama 3.1 8B (Option: `std-8b`)
- **Memory Footprint:** ~4.9GB.
- **Context Window:** Restricted to **2048 tokens** to prevent OOM.
- **GPU Offloading:** Only **12 of 33 layers** offloaded to stay within unified memory limits.

---

## 🛠 Project Structure

- `models/ii-search/`: The 4B AI search model.
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
