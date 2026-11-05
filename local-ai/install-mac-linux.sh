#!/usr/bin/env bash
# Run from this folder:  bash install-mac-linux.sh
set -e

echo "== 1/4 Installing Ollama (free) =="
if ! command -v ollama >/dev/null; then
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "Mac: download Ollama from https://ollama.com/download, open it once, then re-run this script."
    exit 1
  fi
  curl -fsSL https://ollama.com/install.sh | sh
fi

echo "== 2/4 Low-RAM settings =="
SETTINGS=(
  "OLLAMA_FLASH_ATTENTION=1"
  "OLLAMA_KV_CACHE_TYPE=q8_0"
  "OLLAMA_MAX_LOADED_MODELS=1"
  "OLLAMA_NUM_PARALLEL=1"
  "OLLAMA_KEEP_ALIVE=2m"
)

echo "== 3/4 Restarting Ollama so settings apply =="
if [[ "$(uname)" == "Darwin" ]]; then
  for s in "${SETTINGS[@]}"; do launchctl setenv "${s%%=*}" "${s#*=}"; done
  osascript -e 'quit app "Ollama"' || true
  sleep 2; open -a Ollama; sleep 5
else
  sudo mkdir -p /etc/systemd/system/ollama.service.d
  { echo "[Service]"; for s in "${SETTINGS[@]}"; do echo "Environment=\"$s\""; done; } \
    | sudo tee /etc/systemd/system/ollama.service.d/low-ram.conf >/dev/null
  sudo systemctl daemon-reload
  sudo systemctl restart ollama
  sleep 3
fi

echo "== 4/4 Downloading Qwen3.5 9B (~6.6 GB) and building your models =="
ollama pull qwen3.5:9b
ollama create my-ai      -f ./Modelfile
ollama create my-ai-fast -f ./Modelfile.fast

echo
echo "Done!"
echo "  Deep mode:  ollama run my-ai"
echo "  Fast mode:  ollama run my-ai-fast --think=false"
