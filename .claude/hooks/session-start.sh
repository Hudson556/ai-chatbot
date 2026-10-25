#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

dir="$CLAUDE_PROJECT_DIR/.claude/hooks"
"$dir/install-rea.sh"

# Expose rea and its tool settings to the session's shell commands too.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "source \"$dir/rea-env.sh\"" >> "$CLAUDE_ENV_FILE"
fi
