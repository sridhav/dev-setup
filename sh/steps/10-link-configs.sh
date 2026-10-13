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

# A link this repo used to create and no longer does (a renamed file, say) is
# left behind pointing at nothing. Remove only that: a symlink in a directory
# we manage whose target is inside this repo and has gone. Real files, and
# machine-only files in ~/.zsh.d, are never touched.
dirs=""
for entry in "${LINKS[@]}"; do
  dir="$(dirname "${entry#*|}")"
  case "$dirs" in *"|$dir|"*) continue ;; esac
  dirs="$dirs|$dir|"
done
stale=0
for entry in "${LINKS[@]}"; do
  dir="$(dirname "${entry#*|}")"
  case "$dirs" in *"|$dir|"*) dirs="${dirs//"|$dir|"/}" ;; *) continue ;; esac
  [[ -d "$dir" ]] || continue
  for link in "$dir"/*; do
    [[ -L "$link" ]] || continue
    target="$(readlink "$link")"
    case "$target" in "$DOTFILES"/*) ;; *) continue ;; esac
    [[ -e "$target" ]] && continue
    info "stale link (target gone): $link → $target"
    run rm "$link"
    stale=$((stale + 1))
  done
done
((stale)) || skip "no stale links"
