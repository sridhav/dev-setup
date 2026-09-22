#!/usr/bin/env bash
# List Homebrew packages on this machine that are missing from sh/packages.sh.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

comm -23 <(brew leaves | sort) <(printf '%s\n' "${BREW_FORMULAE[@]}" | sort) | sed 's/^/  formula: /'
if is_macos; then
  comm -23 <(brew list --cask -1 | sort) <(printf '%s\n' "${CASKS[@]}" | sort) | sed 's/^/  cask:    /'
fi
