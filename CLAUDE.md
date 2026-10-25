# CLAUDE.md

## REA (reverse engineering) setup

Cloud sessions install REA via `.claude/hooks/session-start.sh` and register its
MCP server (`rea`) from `.mcp.json`. The `reverse-engineer-anything` skill lives in
`.claude/skills/`. Tool paths and `REA_*` settings come from `.claude/hooks/rea-env.sh`.

- **Browser scenarios:** use `"executable_path": "/root/.local/bin/rea-chromium"`
  with `"mode": "launch"`. Plain `/opt/pw-browsers/chromium` cannot reach public sites
  because REA drops the proxy environment when launching browsers.
- **Network:** the environment's network policy blocks most public websites and
  GitHub downloads. A `connect_rejected` / navigation failure on a public URL is a
  policy denial; report the host rather than retrying.
- **Installed engines:** tshark, apktool, adb (no devices in cloud), sigrok-cli,
  objdump, gdb, binwalk 3.1.0, ILSpy (`ilspycmd`), mitmdump, unblob, Frida.
- **Not available:** Ghidra, JADX MCP, IDA, Kuna, so native decompilation
  (`decompile`, `procedure_pseudo_code`, call graphs) is unavailable. Extracting a
  Ghidra 12.1.x release to `~/.local/ghidra` enables it automatically.
