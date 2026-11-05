# Local AI: Qwen3.5 9B

## Install (one command, run from this folder)
- **Windows:** `powershell -ExecutionPolicy Bypass -File .\install-windows.ps1`
- **Mac/Linux:** `bash install-mac-linux.sh`

## Use
| Mode | Command | Best for |
|---|---|---|
| Deep (thinks first) | `ollama run my-ai` | Analysis, math, multi-step logic |
| Fast | `ollama run my-ai-fast --think=false` | Quick questions, chat |

## Files
- `Modelfile`: deep-mode settings and personality
- `Modelfile.fast`: fast-mode settings
- After editing either one, rebuild: `ollama create my-ai -f Modelfile`

## Check RAM use
`ollama ps` shows what's loaded and how much memory it's using.
