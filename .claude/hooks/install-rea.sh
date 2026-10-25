#!/bin/bash
# Installs Node.js 24, the REA (Reverse Engineer Anything) CLI, and the optional
# analysis tools REA drives (tshark, apktool, adb, sigrok, binwalk, ILSpy,
# mitmproxy, unblob, Ghidra). Idempotent; safe to run concurrently (serialized with flock).
# Core steps fail the script; optional tools are best effort and only warn.
set -euo pipefail

NODE_VERSION="24.22.1"
NODE_SHA256="6c172a9ab6718f7b801fb5a7bd486af2ee5e32758086a04b84fcce2aa77095e6"
REA_VERSION="6.8.0"
BINWALK_VERSION="3.1.0"
ILSPYCMD_VERSION="9.1.0.7988"
GHIDRA_VERSION="12.1.4"
GHIDRA_DEB_URL="https://kali.download/kali/pool/main/g/ghidra/ghidra_12.1.4+ds-0kali1_amd64.deb"
GHIDRA_DEB_SHA256="128b96ae74b22eb508401378950a6b8eb3274c2e29b50f10d1a59f1fca3caad6"
GHIDRA_DIR="$HOME/.local/ghidra"
NODE_DIR="$HOME/.local/node24"
PY_DIR="$HOME/.local/rea-py"
REA_BIN="$NODE_DIR/bin/rea"

mkdir -p "$HOME/.local/bin"
exec 9>"$HOME/.local/.install-rea.lock"
flock 9

warn() { echo "install-rea: warning: $*" >&2; }

# --- Core: Node.js 24 + REA -------------------------------------------------
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

# Chromium wrapper: REA launches browsers with a scrubbed environment, so pass
# the session's egress proxy explicitly or public pages fail to load.
cat > "$HOME/.local/bin/rea-chromium" <<'EOF'
#!/bin/bash
proxy="${HTTPS_PROXY:-${https_proxy:-}}"
if [ -z "$proxy" ] && [ -r /root/.ccr/README.md ]; then
  port="$(grep -oE '127\.0\.0\.1:[0-9]+' /root/.ccr/README.md | head -1 | cut -d: -f2)"
  [ -n "$port" ] && proxy="http://127.0.0.1:$port"
fi
args=()
[ -n "$proxy" ] && args+=("--proxy-server=$proxy" "--proxy-bypass-list=<-loopback>;localhost;127.0.0.1")
exec /opt/pw-browsers/chromium "${args[@]}" "$@"
EOF
chmod +x "$HOME/.local/bin/rea-chromium"

# --- Optional analysis tools (best effort) ----------------------------------
# rea-mcp.sh passes --core-only so MCP startup is not held up by these.
if [ "${1:-}" = "--core-only" ]; then
  exit 0
fi

apt_pkgs=()
command -v tshark >/dev/null || apt_pkgs+=(tshark)
command -v apktool >/dev/null || apt_pkgs+=(apktool)
command -v adb >/dev/null || apt_pkgs+=(adb)
command -v sigrok-cli >/dev/null || apt_pkgs+=(sigrok-cli)
command -v dotnet >/dev/null || apt_pkgs+=(dotnet-sdk-8.0)
if [ ${#apt_pkgs[@]} -gt 0 ]; then
  { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${apt_pkgs[@]}"; } >&2 \
    || warn "apt install failed: ${apt_pkgs[*]}"
fi

if [ "$("$HOME/.cargo/bin/binwalk" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)" != "$BINWALK_VERSION" ]; then
  if command -v cargo >/dev/null; then
    cargo install --locked "binwalk@$BINWALK_VERSION" >&2 || warn "binwalk build failed"
  else
    warn "cargo not found; skipping binwalk"
  fi
fi

if command -v dotnet >/dev/null && [ ! -x "$HOME/.dotnet/tools/ilspycmd" ]; then
  dotnet tool install --global ilspycmd --version "$ILSPYCMD_VERSION" >&2 || warn "ilspycmd install failed"
fi

if [ ! -x "$PY_DIR/bin/mitmdump" ] || [ ! -x "$PY_DIR/bin/unblob" ]; then
  { python3 -m venv "$PY_DIR" && "$PY_DIR/bin/pip" install -q mitmproxy unblob; } >&2 || warn "mitmproxy/unblob install failed"
fi

# Ghidra for native decompilation. GitHub release downloads are not reachable
# from cloud sessions, so use Kali's build of the same release (pinned digest).
if ! grep -qx "application.version=$GHIDRA_VERSION" "$GHIDRA_DIR/Ghidra/application.properties" 2>/dev/null; then
  if ! command -v /usr/lib/jvm/java-25-openjdk-amd64/bin/java >/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends openjdk-25-jdk-headless >&2 \
      || warn "openjdk-25 install failed"
  fi
  gtmp="$(mktemp -d)"
  if curl -fsSL --retry 3 -o "$gtmp/ghidra.deb" "$GHIDRA_DEB_URL" \
    && echo "$GHIDRA_DEB_SHA256  $gtmp/ghidra.deb" | sha256sum -c - >&2 \
    && dpkg-deb -x "$gtmp/ghidra.deb" "$gtmp/x"; then
    rm -rf "$GHIDRA_DIR"
    mv "$gtmp/x/usr/share/ghidra" "$GHIDRA_DIR"
  else
    warn "Ghidra $GHIDRA_VERSION download or verification failed"
  fi
  rm -rf "$gtmp"
fi

exit 0
