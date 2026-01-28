$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = $PSScriptRoot
$BinDir = Join-Path $ScriptDir "build\bin"
$ModelPath = Join-Path $ScriptDir "models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf"
$ExePath = Join-Path $BinDir "llama-server.exe"

# Validation
if (-not (Test-Path $ExePath)) {
    Write-Error "Server executable not found at: $ExePath"
}
if (-not (Test-Path $ModelPath)) {
    Write-Error "Model file not found at: $ModelPath"
}

# Run Server
Write-Host "=============================================="
Write-Host "Starting BitNet b1.58 Inference Server"
Write-Host "URL: http://localhost:8080/v1"
Write-Host "Model: $ModelPath"
Write-Host "Limit: 512 tokens per response"
Write-Host "Hit Ctrl+C to stop"
Write-Host "=============================================="

# Ensure local DLLs are found
$env:PATH = "$BinDir;$env:PATH"

# -c 2048: context size
& $ExePath -m $ModelPath -c 2048 --port 8080 --host 0.0.0.0 -ngl 0 -n 512

# Verification Hint
Write-Host "`n[Check] Open http://localhost:8080/v1/models in your browser."
Write-Host "[Info] If you see JSON, the server is healthy!"
Write-Host "[Instruction] In Agent Zero Settings, set BOTH 'Main' and 'Utility' models to:"
Write-Host "    - Provider: Other (OpenAI compatible)"
Write-Host "    - URL: http://172.27.224.1:8080/v1"
Write-Host "    - Model: bitnet-b1.58-2B-4T"


