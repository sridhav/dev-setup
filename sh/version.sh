#!/usr/bin/env bash
# Which version this Mac is on, and whether it's behind the remote.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
g() { git -C "$DOTFILES" "$@"; }

if ! g rev-parse -q --verify HEAD >/dev/null; then
  echo "No versions yet: nothing has been committed. See README → Version control → First-time setup."
  exit 0
fi

printf 'version:  %s\n' "$(g describe --tags --always --dirty)"
printf 'commit:   %s\n' "$(g log -1 --format='%h  %s  (%cr)')"
branch="$(g symbolic-ref --short -q HEAD || echo "detached: rolled back, 'make update' returns to $DEFAULT_BRANCH")"
printf 'branch:   %s\n' "$branch"
if g rev-parse '@{upstream}' >/dev/null 2>&1; then
  g fetch --quiet 2>/dev/null || warn "couldn't reach the remote; showing the last known state"
  printf 'behind:   %s commit(s)  → make update\n' "$(g rev-list --count 'HEAD..@{upstream}')"
  printf 'ahead:    %s commit(s)  → make push\n' "$(g rev-list --count '@{upstream}..HEAD')"
else
  printf 'remote:   none yet\n'
fi
