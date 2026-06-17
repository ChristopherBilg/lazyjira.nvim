#!/usr/bin/env bash
# Type-check the plugin with lua-language-server.
#
# Neovim ships its LuaCATS type definitions (e.g. `vim.api.keyset.win_config`)
# inside $VIMRUNTIME. We append that path to the workspace library at check time
# so those types resolve, while keeping the committed `.luarc.json` portable.
#
# Requires: nvim, jq, lua-language-server on PATH.
set -euo pipefail

VIMRUNTIME=$(nvim --headless -u NONE +'lua io.write(vim.env.VIMRUNTIME or "")' +qa 2>/dev/null)
if [ -z "$VIMRUNTIME" ]; then
  echo "scripts/typecheck.sh: could not determine VIMRUNTIME (is nvim installed?)" >&2
  exit 1
fi

config="$(mktemp)"
trap 'rm -f "$config"' EXIT
jq --arg vr "$VIMRUNTIME" '.["workspace.library"] += [$vr]' .luarc.json >"$config"

rm -rf .luals-log
# lua-language-server exits non-zero when it finds problems at the given check level.
lua-language-server --check . \
  --configpath "$config" \
  --checklevel=Warning \
  --logpath=.luals-log
