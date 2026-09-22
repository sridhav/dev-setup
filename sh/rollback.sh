#!/usr/bin/env bash
# Put this Mac back on an earlier version, then re-apply it.
#   sh/rollback.sh <commit-or-tag>     (see sh/history.sh)
# Only this Mac changes. `make update` returns it to the latest.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
g() { git -C "$DOTFILES" "$@"; }

ref="${1:-}"
[[ -n "$ref" ]] || { echo "usage: sh/rollback.sh <commit-or-tag>   (make history lists them)" >&2; exit 2; }
g rev-parse --verify --quiet "$ref^{commit}" >/dev/null || { echo "unknown version: $ref" >&2; exit 2; }
if [[ -n "$(g status --porcelain)" ]]; then
  g status --short
  warn "Uncommitted changes. Run 'make push' first."
  exit 1
fi

step "Roll back to $ref"
g checkout --quiet --detach "$ref"
ok "on $(g log -1 --format='%h  %s')"
"$SCRIPTS/install.sh"
# Plugins must match that version's lazy-lock.json too.
nvim --headless "+Lazy! restore" +qa
warn "This Mac is pinned to $ref. Run 'make update' to return to the latest."
