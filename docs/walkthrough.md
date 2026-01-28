# Walkthrough: Agent Zero + BitNet b1.58

This guide covers how to run your fully local **Agent Zero** and **BitNet** setup on your Windows ARM64 device.

## 🚀 How to Run

To start the entire system (Server + Agent), run this single command in a PowerShell terminal:

```powershell
cd "C:\Users\Amari\.gemini\antigravity\scratch\BitNet"
.\start_all.ps1
```

### What happens when you run it:
1.  **BitNet Server starts**: A new terminal window will open automatically to run the native inference server.
2.  **Health Check**: The script waits until the server is fully awake.
3.  **Agent Zero starts**: The Docker container launches with the **official image** and corrected volume mounts (`/a0/tmp/settings.json` and `/a0/.env`).
4.  **Auto-Bridge**: The script now **automatically probes** all your network adapters to find the one where the BitNet brain is actually listening (bypassing any Cloudflare WARP/WSL conflicts).

---

## ✅ Verification Steps

1.  **Open the UI**: Go to [http://localhost:50001](http://localhost:50001) in your browser.
2.  **Start a Chat**: Type a simple greeting.
3.  **Observation**:
    -   **Web UI**: You should see "Thinking..." or "Searching Memory...".
    -   **BitNet Window**: You should see text scrolling as the model calculates the response.

---

## 🛠️ Configuration Snapshot

I have hard-coded the following settings into your `.agent-zero` folder to ensure it stays local:

| Component | Provider | URL | Model |
|-----------|----------|-----|-------|
| **Chat Model** | `other` | `http://host.docker.internal:8080/v1` | `bitnet-b1.58-2B-4T` |
| **Utility Model** | `other` | `http://host.docker.internal:8080/v1` | `bitnet-b1.58-2B-4T` |
| **API Key** | `sk-local` | N/A | N/A |

---

## ⚠️ Known Model Behavior (1-Bit)

Since **BitNet b1.58 (2B)** is a highly experimental 1-bit model:
-   **Speed**: It runs on your CPU. It may take 5-10 seconds to generate the first token.
-   **Accuracy**: It is a 2B model; its reasoning is simpler than GPT-4 or Claude.
-   **Repetition**: If the model gets stuck (e.g., `!!!!!`), I have set a **512-token limit** to cut it off. You can try refreshing the chat to reset its context.

---

## 📦 Project Repository
The code and build scripts are version-controlled here:
[Bollo444/agent-zero-bitnet-b1.58-2B-4T](https://github.com/Bollo444/agent-zero-bitnet-b1.58-2B-4T)
