# Run in PowerShell: right-click Start > Terminal, then:  powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
$env:Path += ";$env:LOCALAPPDATA\Programs\Ollama"
ollama pull gemma4:12b          # main model (~8 GB)
ollama create my-ai -f .\Modelfile
Write-Host "Done. Chat with:  ollama run my-ai"
