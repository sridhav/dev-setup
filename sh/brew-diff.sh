#!/usr/bin/env bash
# List Homebrew packages on this Mac that are missing from sh/packages.sh.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

comm -23 <(brew leaves | sort) <(printf '%s\n' "${FORMULAE[@]}" | sort) | sed 's/^/  formula: /'
comm -23 <(brew list --cask -1 | sort) <(printf '%s\n' "${CASKS[@]}" | sort) | sed 's/^/  cask:    /'
