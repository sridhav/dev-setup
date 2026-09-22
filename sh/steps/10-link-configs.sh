#!/usr/bin/env bash
# Symlink configs from this repo into ~ (existing files are backed up).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Link configs"
for entry in "${LINKS[@]}"; do
  src="$DOTFILES/${entry%%|*}"
  dst="${entry#*|}"
  if ((!FORCE)) && [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then skip "$dst"; continue; fi
  run mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    bak="$BACKUP_DIR/replaced/${dst#"$HOME"/}"
    run mkdir -p "$(dirname "$bak")"
    info "backing up existing $dst → $bak"
    run mv "$dst" "$bak"
  fi
  run ln -s "$src" "$dst"
  ok "$dst → $src"
done
