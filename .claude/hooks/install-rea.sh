#!/bin/bash
# Installs Node.js 24 and the REA (Reverse Engineer Anything) CLI into ~/.local.
# Idempotent; safe to run concurrently (serialized with flock).
set -euo pipefail

NODE_VERSION="24.22.1"
NODE_SHA256="6c172a9ab6718f7b801fb5a7bd486af2ee5e32758086a04b84fcce2aa77095e6"
REA_VERSION="6.8.0"
NODE_DIR="$HOME/.local/node24"
REA_BIN="$NODE_DIR/bin/rea"

mkdir -p "$HOME/.local"
exec 9>"$HOME/.local/.install-rea.lock"
flock 9

if [ "$("$NODE_DIR/bin/node" --version 2>/dev/null || true)" != "v$NODE_VERSION" ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  tarball="node-v$NODE_VERSION-linux-x64.tar.xz"
  curl -fsSL --retry 3 "https://nodejs.org/dist/v$NODE_VERSION/$tarball" -o "$tmp/$tarball"
  echo "$NODE_SHA256  $tmp/$tarball" | sha256sum -c - >&2
  rm -rf "$NODE_DIR"
  mkdir -p "$NODE_DIR"
  tar -xJf "$tmp/$tarball" -C "$NODE_DIR" --strip-components=1
fi

export PATH="$NODE_DIR/bin:$PATH"
if [ "$("$REA_BIN" --version 2>/dev/null | tr -d '[:space:]' || true)" != "$REA_VERSION" ]; then
  npm install --global --no-fund --no-audit "rea-agents@$REA_VERSION" >&2
fi
