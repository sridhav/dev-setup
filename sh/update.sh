#!/usr/bin/env bash
# Run this on every Mac: move to the latest version on the remote and apply it.
# Stops (changing nothing) if this Mac has uncommitted config edits, so local
# work is never overwritten. Only fast-forwards: no merge commits.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"
g() { git -C "$DOTFILES" "$@"; }

step "Check for local changes"
if [[ -n "$(g status --porcelain)" ]]; then
  g status --short
  warn "This Mac has config changes that aren't pushed. Run 'make push' first (or 'git -C $DOTFILES stash' to set them aside)."
  exit 1
fi
ok "clean"

# After `make rollback`, the repo sits on an old commit; go back to main.
if ! g symbolic-ref -q HEAD >/dev/null; then
  info "leaving rollback, back to $DEFAULT_BRANCH"
  g checkout --quiet "$DEFAULT_BRANCH"
fi

step "Fetch latest"
if ! g rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  warn "No remote set up yet. See README → 'Version control'."
  exit 1
fi
g fetch --quiet --tags
incoming="$(g log --oneline 'HEAD..@{upstream}')"
if [[ -z "$incoming" ]]; then
  skip "already on the latest version ($(g rev-parse --short HEAD))"
else
  printf '%s\n' "$incoming" | sed 's/^/    /'
  ((DRY_RUN)) && info "dry run: not moving to these"
  ((DRY_RUN)) || g merge --ff-only --quiet '@{upstream}' || {
    warn "This Mac has commits the remote doesn't. Run 'make push' first."
    exit 1
  }
  ((DRY_RUN)) || ok "now on $(g rev-parse --short HEAD)"
fi

"$SCRIPTS/install.sh"
"$SCRIPTS/plugins.sh"
# Clear the "updates available" notice.
run rm -f "$HOME/.cache/dev-setup/behind"
