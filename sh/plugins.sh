#!/usr/bin/env bash
# Sync shell, tmux, and Neovim plugins. oh-my-zsh and zsh/tmux plugins move to
# their latest versions; Neovim plugins go to the versions in lazy-lock.json.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

step "Sync plugins"
info "oh-my-zsh"
run env ZSH="$HOME/.oh-my-zsh" zsh "$HOME/.oh-my-zsh/tools/upgrade.sh" >/dev/null || warn "oh-my-zsh update failed"

custom="$HOME/.oh-my-zsh/custom"
for d in "$custom"/plugins/*/ "$custom"/themes/*/; do
  [[ -d "$d/.git" ]] || continue
  d="${d%/}"
  info "${d##*/}"
  run git -C "$d" pull --ff-only --quiet || warn "${d##*/} update failed"
done

info "tmux plugins"
run "$HOME/.tmux/plugins/tpm/bin/update_plugins" all >/dev/null || warn "tmux plugin update failed"

info "Neovim plugins (lazy-lock.json)"
run nvim --headless "+Lazy! restore" +qa
ok "plugins synced"
