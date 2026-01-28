$Url = "http://localhost:8080/v1/chat/completions"
$Body = @{
    model = "bitnet-b1.58-2B-4T"
    messages = @(
        @{ role = "user"; content = "Say Hello" }
    )
    max_tokens = 50
    temperature = 0
} | ConvertTo-Json

Write-Host "Testing Chat Completion..."
try {
    $Response = Invoke-RestMethod -Uri $Url -Method Post -Body $Body -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ SUCCESS!"
    Write-Host "Response: $($Response.choices[0].message.content)"
} catch {
    Write-Host "❌ FAILED"
    Write-Host "Exception: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Host "Details: $($_.ErrorDetails.Message)" }
}
