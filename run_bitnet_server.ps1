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
Write-Host "Swagger UI: http://localhost:8080/docs"
Write-Host "Model: $ModelPath"
Write-Host "Hit Ctrl+C to stop"
Write-Host "=============================================="

# Ensure local DLLs are found (Windows loads from exe dir by default, but optional safety)
$env:PATH = "$BinDir;$env:PATH"

& $ExePath -m $ModelPath -c 2048 --port 8080 --host 127.0.0.1 --n-gpu-layers 0 -ngl 0
