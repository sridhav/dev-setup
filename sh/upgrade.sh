#!/usr/bin/env bash
# Move this machine to newer versions, then run push.sh to share them with the others.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

step "Upgrade Homebrew packages"
brew update
brew upgrade "${BREW_FORMULAE[@]}" || warn "some formulae failed to upgrade"
if is_macos; then
  brew upgrade --cask "${CASKS[@]}" || warn "some casks failed to upgrade"
else
  step "Upgrade apt packages, Docker and Ghostty"
  as_root apt-get update
  as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --only-upgrade \
    "${APT_PACKAGES[@]}" docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    || warn "some apt packages failed to upgrade"
  # The ghostty-ubuntu installer also updates an existing install.
  (cd "$(mktemp -d)" && bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)") || warn "ghostty update failed"
fi

step "Upgrade Neovim plugins (writes new versions to lazy-lock.json)"
nvim --headless "+Lazy! sync" +qa

"$SCRIPTS/plugins.sh"

step "Changes to push"
git -C "$DOTFILES" status --short
