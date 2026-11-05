#!/usr/bin/env bash
# Run:  bash install-mac-linux.sh
set -e
if [[ "$(uname)" == "Darwin" ]]; then
  echo "Mac: download Ollama from https://ollama.com/download, open it once, then re-run this script."
  command -v ollama >/dev/null || exit 1
else
  curl -fsSL https://ollama.com/install.sh | sh
fi
ollama pull gemma4:12b          # main model (~8 GB)
ollama create my-ai -f ./Modelfile
echo "Done. Chat with:  ollama run my-ai"
