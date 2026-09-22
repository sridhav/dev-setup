#!/usr/bin/env bash
# Show uncommitted changes and any configs that aren't linked to this repo.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

git -C "$DOTFILES" status --short --branch
all_linked=1
for entry in "${LINKS[@]}"; do
  src="$DOTFILES/${entry%%|*}"
  dst="${entry#*|}"
  if [[ "$(readlink "$dst" 2>/dev/null)" != "$src" ]]; then
    warn "not linked: $dst"
    all_linked=0
  fi
done
((all_linked)) && ok "all configs linked" || warn "run make install to link them"
