#!/usr/bin/env bash
# Neovim plugins, pinned by nvim/lazy-lock.json.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Neovim plugins (pinned by lazy-lock.json)"
set_aside "$HOME/.local/share/nvim/lazy"
if [[ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]]; then
  skip "lazy.nvim plugins (make plugins re-syncs them)"
  exit 0
fi
# restore installs exactly the commits in lazy-lock.json. Mason tools and
# treesitter parsers then install themselves on first interactive launch.
run nvim --headless "+Lazy! restore" +qa
ok "Neovim plugins"
