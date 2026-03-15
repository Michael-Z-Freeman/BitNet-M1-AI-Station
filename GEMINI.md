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

## ⚙️ Optimization for 8GB RAM

To prevent `OutOfMemory` (status 5) errors on 8GB hardware, the following optimizations are applied in `start_server.sh`:

- **Context Window:** Restricted to **2048 tokens** for 8B models to minimize KV cache RAM usage.
- **GPU Offloading (`-ngl`):**
  - `std-8b`: Set to **12 layers** (out of 33) to stay within the ~5.7GB usable GPU RAM limit.
  - `2b`: Full GPU offloading (31 layers) for maximum speed.
- **Ports:** Server runs on `8000`, WebUI runs on `8080`.

## 🛠 Project Structure

- `bitnet-repo/`: Core `bitnet.cpp` (llama.cpp fork) compiled with Apple Clang.
- `models/`: Weights for BitNet 2B, 8B, and Standard Llama 3.1.
- `.venv/`: Python 3.9 environment for BitNet.
- `.venv-webui/`: Python 3.12 environment for Open WebUI.
- `launch_ai_station.sh`: Master script used by the automation service.

## 📝 Maintenance
- To switch models: Stop the automation or kill the server process, edit `launch_ai_station.sh` to point to your preferred model, and restart the service.
- Logs are located at `server.log`, `webui.log`, and `launchd_stderr.log`.
