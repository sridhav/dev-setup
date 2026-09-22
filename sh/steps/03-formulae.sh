#!/usr/bin/env bash
# Homebrew formulae listed in sh/packages.sh.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Homebrew formulae"
installed="$(brew list --formula -1 2>/dev/null || true)"
for f in "${FORMULAE[@]}"; do
  if grep -qx "$f" <<<"$installed"; then skip "$f"; continue; fi
  info "installing $f"
  run brew install "$f"
  ok "$f"
done
