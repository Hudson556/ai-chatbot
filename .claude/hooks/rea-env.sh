#!/bin/bash
# Environment for the REA CLI and MCP server. Sourced by rea-mcp.sh and
# session-start.sh; each tool is wired only when it is installed.

export PATH="$HOME/.local/node24/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.dotnet/tools:$PATH"

set_if_exec() { [ -x "$2" ] && export "$1=$2"; return 0; }
set_if_exec REA_TSHARK_COMMAND /usr/bin/tshark
set_if_exec REA_CAPINFOS_COMMAND /usr/bin/capinfos
set_if_exec REA_APKTOOL_COMMAND /usr/bin/apktool
set_if_exec REA_ADB_PATH /usr/bin/adb
set_if_exec REA_SIGROK_COMMAND /usr/bin/sigrok-cli
set_if_exec REA_OBJDUMP_COMMAND /usr/bin/objdump
set_if_exec REA_GDB_COMMAND /usr/bin/gdb
set_if_exec REA_BINWALK_COMMAND "$HOME/.cargo/bin/binwalk"
set_if_exec REA_ILSPY_CMD_PATH "$HOME/.dotnet/tools/ilspycmd"
set_if_exec REA_MITMDUMP_COMMAND "$HOME/.local/rea-py/bin/mitmdump"
set_if_exec REA_UNBLOB_COMMAND "$HOME/.local/rea-py/bin/unblob"
# Picked up automatically if a Ghidra 12.1.x release is extracted here.
[ -x "$HOME/.local/ghidra/support/analyzeHeadless" ] && export GHIDRA_INSTALL_DIR="$HOME/.local/ghidra"
unset -f set_if_exec
