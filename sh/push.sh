#!/usr/bin/env bash
# Commit and push local config changes.
#   sh/push.sh                   default message names this Mac
#   sh/push.sh "add lazygit"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

msg="${1:-update dev setup from $(scutil --get ComputerName 2>/dev/null || hostname -s)}"
git -C "$DOTFILES" add -A
if git -C "$DOTFILES" diff --cached --quiet; then
  echo "Nothing to push."
  exit 0
fi
git -C "$DOTFILES" commit -m "$msg"
git -C "$DOTFILES" push
