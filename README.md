# BitNet 1.58 & Llama 3.1 AI Station (8GB M1 Mac)

This project provides a high-performance, memory-efficient AI inference station running on Apple Silicon. It leverages the cutting-edge **BitNet 1.58-bit** technology from Microsoft and the **Llama 3.1 8B** model, optimized for an 8GB RAM footprint.

## 🚀 Quick Start

### 1. Start the Model Server
In a terminal, run the server with your choice of model:
```bash
# Option A: Standard Llama 3.1 8B (High Quality, 12 GPU Layers, 2k Context)
./start_server.sh std-8b

# Option B: Microsoft BitNet 2B 1.58-bit (Ultra Fast, Full Metal Acceleration)
./start_server.sh 2b

# Option C: Experimental BitNet 8B 1.58-bit (CPU Only, Experimental)
./start_server.sh 8b
```

### 2. Start the Web Interface
In a **separate** terminal, start the Open WebUI:
```bash
./start_webui.sh
```

### 3. Access the AI
Open your browser to:
- **Local:** `http://localhost:8080`
- **LAN:** `http://192.168.1.77:8080` (or your Mac's IP)

---

## 🤖 Automation (macOS LaunchAgents)

The system is configured to start automatically on login using macOS `launchd`.

### Installation
1. Move the configuration file:
   ```bash
   mv com.ai.station.startup.plist ~/Library/LaunchAgents/
   ```
2. Load the service:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.ai.station.startup.plist
   ```

### Management
- **Stop Automation:** `launchctl unload ~/Library/LaunchAgents/com.ai.station.startup.plist`
- **Force Kill Background Processes:** `pkill -f llama-server && pkill -f open-webui`
- **Check Status:** `launchctl list | grep com.ai.station.startup`

---

## ⚙️ Optimization for 8GB RAM (Technical Reasoning)

To prevent `OutOfMemory` (status 5) errors on 8GB hardware, we applied the following critical tuning in `start_server.sh`:

### 1. Context Window (`-c 2048`)
- **The Challenge:** Llama 3.1 default context is 128k tokens, requiring ~16GB RAM for the KV cache alone.
- **The Fix:** Restricted to **2048 tokens**. This minimizes the "memory" footprint of the conversation, leaving space for the model weights.

### 2. GPU Layer Offloading (`-ngl 12`)
- **The Challenge:** Total unified memory available to the GPU on an 8GB M1 is ~5.7GB. The 8B model (4.9GB) + compute buffers exceeds this if fully offloaded.
- **The Fix:** Offloaded only **12 of 33 layers** to the GPU. This prevents the GPU driver from crashing during the "math-heavy" inference phase.

### 3. BitNet 1.58-bit Efficiency
- The **2B model** uses ternary weights (-1, 0, 1), resulting in a tiny **1.2GB** footprint. This allows for **100% GPU offloading** and high speeds (~33 t/s) even on base M1 hardware.

## 🛠 Project Structure

- `bitnet-repo/`: Core `bitnet.cpp` (llama.cpp fork).
- `models/`: Weights for BitNet 2B, 8B, and Standard Llama 3.1.
- `.venv/`: Python 3.9 environment for BitNet.
- `.venv-webui/`: Python 3.12 environment for Open WebUI.

## 🏗 Initial Setup (Reproducing from Scratch)

If you need to recreate the environments or recompile the code:

### 1. Build bitnet.cpp
```bash
git clone --recursive https://github.com/microsoft/BitNet.git bitnet-repo
cd bitnet-repo
mkdir build && cd build
cmake .. -DGGML_ACCELERATE=OFF -DGGML_BLAS=OFF -DGGML_METAL=ON
cmake --build . --config Release --parallel 8
```

### 2. Setup Python Environments
```bash
# BitNet Environment (Python 3.9)
uv venv .venv --python 3.9
source .venv/bin/activate
uv pip install -r bitnet-repo/requirements.txt huggingface-hub pip

# WebUI Environment (Python 3.12)
uv venv .venv-webui --python 3.12
source .venv-webui/bin/activate
uv pip install open-webui
```

## 📝 Maintenance
- To switch models: Stop the automation or kill the server process, edit `launch_ai_station.sh` to point to your preferred model, and restart the service.
- Logs are located at `server.log`, `webui.log`, and `launchd_stderr.log`.
