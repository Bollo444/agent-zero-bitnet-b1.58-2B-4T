# File created: 2026-01-28T18:30:00-05:00 (EST)
# Author: Antigravity Agent - Ariel's Workspace

$ErrorActionPreference = "Stop"

$BitNetDir = "C:\Users\Amari\.gemini\antigravity\scratch\BitNet"
$ConfigDir = "C:\Users\Amari\.agent-zero"

# 1. Cleanup old instances
Write-Host "Cleaning up old instances..."
Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force
try { docker rm -f agent-zero 2>$null | Out-Null } catch { }

# 2. Start the BitNet Server
Write-Host "Starting BitNet Server..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$BitNetDir'; .\run_bitnet_server.ps1"

# 3. Wait for server and Find TRUE Host IP
Write-Host "Waiting for server and detecting best bridge IP..."
$BestIP = $null
$MaxReadyRetries = 30
for($i=0; $i -lt $MaxReadyRetries; $i++) {
    # Try localhost first to confirm it's even up
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:8080/v1/models" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($r.StatusCode -eq 200) {
            # Server is up! Now find which bridge IP is open
            $AllIPs = Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
            foreach ($IP in $AllIPs) {
                # Skip loopback and common non-bridge IPs
                if ($IP -eq "127.0.0.1") { continue }
                
                $t = New-Object System.Net.Sockets.TcpClient
                try {
                    $w = $t.BeginConnect($IP, 8080, $null, $null)
                    if ($w.AsyncWaitHandle.WaitOne(200, $false)) {
                        $BestIP = $IP
                        $t.Close()
                        break
                    }
                } catch {} finally { $t.Close() }
            }
            if ($BestIP) { break }
        }
    } catch { }
    
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
}

if (-not $BestIP) {
    Write-Host "`nERROR: Could not find an open bridge IP. Firewall might be blocking external ports."
    exit
}

Write-Host "`nFound Best Bridge IP: $BestIP"

# 4. Update Agent Zero Config with the discovered IP
Write-Host "Updating Agent Zero configuration..."
$SPath = "$ConfigDir\settings.json"
if (Test-Path $SPath) {
    $j = Get-Content $SPath -Raw | ConvertFrom-Json
    $j.chat_model_api_base = "http://host.docker.internal:8080/v1"
    $j.util_model_api_base = "http://host.docker.internal:8080/v1"
    $j.browser_model_api_base = "http://host.docker.internal:8080/v1"
    $j | ConvertTo-Json -Depth 10 | Set-Content $SPath
}

$EPath = "$ConfigDir\.env"
if (Test-Path $EPath) {
    $c = Get-Content $EPath
    $c = $c -replace "CHAT_MODEL_API_BASE=.*", "CHAT_MODEL_API_BASE=http://host.docker.internal:8080/v1"
    $c = $c -replace "UTIL_MODEL_API_BASE=.*", "UTIL_MODEL_API_BASE=http://host.docker.internal:8080/v1"
    Set-Content $EPath $c
}

# 5. Launch Agent Zero
Write-Host "Launching Agent Zero..."
$V1 = "$ConfigDir" + ":/a0/work_dir"
$V2 = "$ConfigDir\settings.json" + ":/a0/tmp/settings.json"
$V3 = "$ConfigDir\.env" + ":/a0/.env"
$HMAP = "host.docker.internal:" + $BestIP

docker run -it --rm --name agent-zero -p 50001:80 -v $V1 -v $V2 -v $V3 --add-host $HMAP agent0ai/agent-zero:latest
