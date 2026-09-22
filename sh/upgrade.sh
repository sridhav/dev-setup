#!/usr/bin/env bash
# Move this Mac to newer versions, then run push.sh to share them with the others.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

step "Upgrade Homebrew packages"
brew update
brew upgrade "${FORMULAE[@]}" || warn "some formulae failed to upgrade"
brew upgrade --cask "${CASKS[@]}" || warn "some casks failed to upgrade"

step "Upgrade Neovim plugins (writes new versions to lazy-lock.json)"
nvim --headless "+Lazy! sync" +qa

"$SCRIPTS/plugins.sh"

step "Changes to push"
git -C "$DOTFILES" status --short
