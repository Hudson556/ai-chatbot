#!/bin/bash
# Launches the REA MCP server, installing it first if the session-start hook
# has not finished yet. Install output goes to stderr to keep stdio clean.
set -euo pipefail

dir="$(dirname "$0")"
[ -x "$HOME/.local/node24/bin/rea" ] || "$dir/install-rea.sh" --core-only >&2
source "$dir/rea-env.sh"
exec rea mcp "$@"
