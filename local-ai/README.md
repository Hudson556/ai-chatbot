# Local AI: Qwen3.5 9B

## Install (one command, run from this folder)
- **Windows:** double-click `INSTALL-WINDOWS.bat` (or run `powershell -ExecutionPolicy Bypass -File .\install-windows.ps1`)
- **Mac/Linux:** `bash install-mac-linux.sh`

## Use
| Mode | Command | Best for |
|---|---|---|
| Coding (thinks first) | `ollama run my-ai` | Writing and debugging code, hard problems |
| Fast | `ollama run my-ai-fast --think=false` | General knowledge, quick questions |

## Files
- `Modelfile`: coding-mode settings and personality
- `Modelfile.fast`: fast-mode settings
- After editing either one, rebuild: `ollama create my-ai -f Modelfile`

## Check RAM use
`ollama ps` shows what's loaded and how much memory it's using.

## Training (optional): make it a stronger coder
| File | GPU | Model |
|---|---|---|
| `training/train-my-ai-coder-9B-kaggle.ipynb` | Kaggle free 2x T4 (32 GB) | **9B** (recommended) |
| `training/train-my-ai-coder.ipynb` | Colab free T4 (15 GB) | 4B only |

Instructions are in the first cell of each notebook. When training finishes:
`ollama create my-ai-coder -f Modelfile.trained` then `ollama run my-ai-coder`
