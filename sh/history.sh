#!/usr/bin/env bash
# Recent versions, newest first. `sh/history.sh 50` shows more.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
git -C "$DOTFILES" rev-parse -q --verify HEAD >/dev/null || { echo "No versions yet: nothing has been committed."; exit 0; }
git -C "$DOTFILES" log -n "${1:-20}" --format='%C(yellow)%h%C(reset)  %C(dim)%ad%C(reset)  %s%C(auto)%d' --date=short
