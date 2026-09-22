#!/usr/bin/env bash
# oh-my-zsh plugins and themes (powerlevel10k, autosuggestions, ...).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "oh-my-zsh plugins and themes"
custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for entry in "${OMZ_PLUGINS[@]}"; do
  git_clone "${entry%%|*}" "${entry#*|}" "$custom/plugins/${entry%%|*}"
done
for entry in "${OMZ_THEMES[@]}"; do
  git_clone "${entry%%|*}" "${entry#*|}" "$custom/themes/${entry%%|*}"
done

# The zshrc's plugins=(...) is the source of truth. Check every plugin in it is
# either built into oh-my-zsh or was cloned above, so one added to the zshrc
# but not to OMZ_PLUGINS in lib.sh can't silently go missing on other Macs.
step "Check every plugin in zshrc is installed"
missing=0
for p in $(sed -n '/^plugins=(/,/)/p' "$DOTFILES/zsh/zshrc" | sed 's/#.*//; s/plugins=(//; s/)//'); do
  if [[ -d "$custom/plugins/$p" ]]; then
    ok "$p"
  elif [[ -d "$HOME/.oh-my-zsh/plugins/$p" ]]; then
    ok "$p (built into oh-my-zsh)"
  elif ((DRY_RUN)); then
    info "$p (installs in a real run)"
  else
    warn "$p is in zsh/zshrc but not installed: add \"$p|<git url>\" to OMZ_PLUGINS in sh/lib.sh"
    missing=1
  fi
done
((missing == 0)) || exit 1
