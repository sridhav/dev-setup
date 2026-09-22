#!/usr/bin/env bash
# zsh as the login shell.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Default shell"
zsh_path="$(command -v zsh)"
if [[ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" == "$zsh_path" ]]; then
  skip "zsh is the login shell"
  exit 0
fi
run chsh -s "$zsh_path"
ok "login shell → $zsh_path"
