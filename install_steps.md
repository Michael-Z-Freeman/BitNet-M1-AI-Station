Here are the step-by-step installation and execution commands for BitNet on Apple Silicon as detailed in the video:

### **1. Install Build Tools**

First, ensure your Mac has the necessary development environment.

* **Install Xcode command-line tools:** `xcode-select --install`
* **Install Homebrew (if not already installed):** `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### **2. Install CMake & LLVM**

Use Homebrew to install the specific compiler and build requirements.

* **Install dependencies:** `brew install cmake`
`brew install llvm@18`
* **Add LLVM 18 to your PATH:**
* **Reload your terminal:** 

### **3. Clone the BitNet Repository**

Download the source code from GitHub.

* **Clone with submodules:** `git clone --recursive https://github.com/microsoft/BitNet.git`
* **Navigate into the directory:** `cd BitNet`

### **4. Set Up Python Environment**

The video recommends using a virtual environment (Conda) with Python 3.9.

* **Create environment:** `conda create -n bitnet-cpp python=3.9`
* **Activate environment:** `conda activate bitnet-cpp`
* **Install Python dependencies:** `pip install -r requirements.txt`

### **5. Download and Prepare the Model**

Download the 2B parameter model from Hugging Face.

* **Install Hugging Face CLI:** `pip install huggingface-hub`
* **Download BitNet 2B checkpoint:** `huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir models/BitNet-b1.58-2B-4T`
* **Build the project and set up environment:** `python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s`

### **6. Run Inference and Benchmarking**

* **To run a prompt and chat with the model:** `python run_inference.py -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf -p "Your prompt here" -n 6 -temp 0`
* **To test performance (Benchmarking):** `python utils/e2e_benchmark.py -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf -n 200 -p 256 -t 4`