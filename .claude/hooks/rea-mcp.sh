#!/bin/bash
# Launches the REA MCP server, installing it first if the session-start hook
# has not finished yet. Install output goes to stderr to keep stdio clean.
set -euo pipefail

"$(dirname "$0")/install-rea.sh" >&2
exec "$HOME/.local/node24/bin/rea" mcp "$@"
