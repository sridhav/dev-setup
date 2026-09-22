#!/usr/bin/env bash
# tmux plugins listed in tmux.conf (catppuccin/tmux, vim-tmux-navigator, ...).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "tmux plugins"
# tmux.conf's `set -g @plugin 'owner/name'` lines are the source of truth; tpm
# clones each one to ~/.tmux/plugins/<name>.
missing=0
for p in $(sed -nE "s/^set -g @plugin ['\"]([^'\"]+)['\"].*/\1/p" "$DOTFILES/tmux/tmux.conf"); do
  if [[ -d "$HOME/.tmux/plugins/${p##*/}" ]]; then skip "$p"; else info "missing $p"; missing=1; fi
done
((missing)) || exit 0
run "$HOME/.tmux/plugins/tpm/bin/install_plugins"
ok "tmux plugins installed"
