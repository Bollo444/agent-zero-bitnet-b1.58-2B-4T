# Diagnostic Report: Agent Zero + BitNet Integration
**Date**: 2026-01-28
**Environment**: Windows ARM64 (Surface Pro), Docker Desktop, Cloudflare WARP

## 1. Project Objective
The goal is to establish a fully local, high-performance integration between **Agent Zero** (running in Docker) and a native **BitNet b1.58** inference server. This "Separation of Concerns" architecture allows the agent to run in its containerized environment while utilizing the host machine's native ARM64 instructions for 1-bit inference, without relying on external APIs.

## 2. Technical Obstacles

### A. Networking Isolation (The Bridge Gap)
*   **The Problem**: In Docker Desktop on Windows, `host.docker.internal` is intended to point to the host. However, on ARM64 systems with multiple virtual switches (WSL, Hyper-V, Default Switch), it often resolves to the **WSL bridge IP (172.27.224.1)**, which is frequently blocked or isolated from the host ports.
*   **The Symptom**: `ConnectionRefusedError: [Errno 111]` when the agent tries to talk to the model server.

### B. Configuration Path Mismatches
*   **The Problem**: Internal source code analysis revealed that Agent Zero's configuration directory inside the container is `/a0/`, not `/app/` (as suggested by some documentation).
*   **The Symptom**: Changes made to `settings.json` or `.env` were being silently ignored because they were mounted to the wrong internal path, causing the agent to fall back to default (OpenRouter) settings.

### C. PowerShell Syntax Fragility
*   **The Problem**: PowerShell on certain Windows ARM64 builds exhibits a bug with multi-line backtick continuations (` ` `) and quotes, leading to `TerminatorExpected` errors on long commands.
*   **The Symptom**: Startup scripts failing to parse, preventing the container from launching.

### D. 1-Bit Model Stability
*   **The Problem**: BitNet models are highly experimental. Using standard "greedy" parameters or the wrong prompt template results in garbled, repetitive, or empty output.
*   **The Symptom**: The agent receives no response or sits in an infinite "Thinking" loop.

## 3. Measures Taken

| Action | Status | Rationale |
| :--- | :--- | :--- |
| **Native Compilation** | ✅ Done | Compiled `bitnet.cpp` (llama-server) specifically for ARM64 to unlock maximum inference speed. |
| **Auto-Probe Networking** | ✅ Done | Implemented a script that scans all network adapters to find the one where port 8080 is actually open. |
| **Path Correction** | ✅ Done | Re-routed Docker mounts to `/a0/tmp/settings.json` and `/a0/.env` to ensure settings are actually loaded. |
| **Lo-Fi Scripting**| ✅ Done | Rewrote the startup logic into a flat, ASCII-only script to bypass PowerShell's parsing bugs. |
| **Parameter Tuning** | ✅ Done | Locked temperature to `0` and applied `ChatML` templates to stabilize the 1-bit model output. |

## 4. Current Status & Next Steps
We have successfully identified the **Default Switch bridge (172.20.240.1)** as the correct route for your specific machine. 

**Definitive Step**: The startup script has been updated to use "Auto-Discovery" to lock this IP in dynamically. If the connection continues to fail, we will hardcode this discovered IP directly into the environment variables to bypass the Docker DNS layer entirely.
