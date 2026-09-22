#!/usr/bin/env bash
# oh-my-zsh.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "oh-my-zsh"
set_aside "$HOME/.oh-my-zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then skip "oh-my-zsh"; exit 0; fi
# KEEP_ZSHRC: our zshrc is linked in step 10. RUNZSH/CHSH: stay non-interactive.
run env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ok "oh-my-zsh"
