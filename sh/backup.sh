#!/usr/bin/env bash
# Copy all configs to ~/.dev-setup-backup/<timestamp>/snapshot without changing anything.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

step "Back up configs → $BACKUP_DIR/snapshot"
run mkdir -p "$BACKUP_DIR/snapshot"
run chmod 700 "$HOME/.dev-setup-backup" "$BACKUP_DIR"
for path in "${BACKUP_PATHS[@]}"; do
  [[ -e "$path" ]] || continue
  dest="$BACKUP_DIR/snapshot/${path#"$HOME"/}"
  run mkdir -p "$(dirname "$dest")"
  # -L: copy what symlinks point to. `|| warn`: a broken link inside a
  # plugin dir shouldn't stop the whole backup.
  run cp -RL "$path" "$dest" || warn "could not fully copy $path"
  ok "$path"
done
