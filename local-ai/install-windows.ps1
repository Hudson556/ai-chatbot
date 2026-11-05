# Run from this folder in PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
$ErrorActionPreference = "Stop"

Write-Host "== 1/4 Installing Ollama (free) =="
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
  winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
  $env:Path += ";$env:LOCALAPPDATA\Programs\Ollama"
}

Write-Host "== 2/4 Low-RAM settings =="
$settings = @{
  OLLAMA_FLASH_ATTENTION   = "1"     # needed for the compressed memory below
  OLLAMA_KV_CACHE_TYPE     = "q8_0"  # ~halves conversation-memory RAM, tiny quality cost
  OLLAMA_MAX_LOADED_MODELS = "1"     # never keep two models in RAM
  OLLAMA_NUM_PARALLEL      = "1"     # one chat at a time (parallel multiplies RAM)
  OLLAMA_KEEP_ALIVE        = "2m"    # free RAM 2 minutes after last message
}
foreach ($k in $settings.Keys) {
  [Environment]::SetEnvironmentVariable($k, $settings[$k], "User")
  Set-Item -Path "env:$k" -Value $settings[$k]
}

Write-Host "== 3/4 Restarting Ollama so settings apply =="
Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
$app = "$env:LOCALAPPDATA\Programs\Ollama\ollama app.exe"
if (Test-Path $app) { Start-Process $app } else { Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden }
Start-Sleep -Seconds 5

Write-Host "== 4/4 Downloading Qwen3.5 9B (~6.6 GB) and building your models =="
ollama pull qwen3.5:9b
ollama create my-ai      -f .\Modelfile
ollama create my-ai-fast -f .\Modelfile.fast

Write-Host ""
Write-Host "Done!"
Write-Host "  Deep mode:  ollama run my-ai"
Write-Host "  Fast mode:  ollama run my-ai-fast --think=false"
