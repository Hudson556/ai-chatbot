# CLAUDE.md

## REA (reverse engineering) setup

Cloud sessions install REA via `.claude/hooks/session-start.sh` and register its
MCP server (`rea`) from `.mcp.json`. The `reverse-engineer-anything` skill lives in
`.claude/skills/`. Tool paths and `REA_*` settings come from `.claude/hooks/rea-env.sh`.

- **Browser scenarios:** use `"executable_path": "/root/.local/bin/rea-chromium"`
  with `"mode": "launch"`. Plain `/opt/pw-browsers/chromium` cannot reach public sites
  because REA drops the proxy environment when launching browsers.
- **Network:** GitHub release downloads are not reachable (only `git clone` of public
  repos). A `connect_rejected` failure is a policy denial; report the host rather
  than retrying. Sites behind Cloudflare bot checks (e.g. canva.com) show a CAPTCHA
  to headless browsers; do not try to evade it.
- **Installed engines:** Ghidra 12.1.4 (Kali build, `~/.local/ghidra`, native
  decompilation), tshark, apktool, adb (no devices in cloud), sigrok-cli, objdump,
  gdb, binwalk 3.1.0, ILSpy (`ilspycmd`), mitmdump, unblob, Frida.
- **Not available:** JADX MCP (Android code decompilation), IDA, Hopper, Kuna.
