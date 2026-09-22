#!/usr/bin/env bash
# zsh as the login shell (macOS and Linux).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Default shell"
if is_macos; then
  zsh_path="/bin/zsh"
  current="$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')"
else
  zsh_path="$(command -v zsh || echo /usr/bin/zsh)" # from apt (step 01)
  current="$(getent passwd "$USER" | cut -d: -f7)"
fi
if [[ "$current" == "$zsh_path" ]]; then
  skip "zsh is the login shell"
  exit 0
fi
# chsh only accepts shells listed in /etc/shells.
if ! grep -qx "$zsh_path" /etc/shells; then
  run as_root sh -c "echo '$zsh_path' >> /etc/shells"
fi
if is_macos; then
  run chsh -s "$zsh_path"
else
  # Through sudo so it doesn't prompt for the account password a second time.
  run as_root chsh -s "$zsh_path" "$USER"
fi
ok "login shell → $zsh_path (takes effect at next login)"
