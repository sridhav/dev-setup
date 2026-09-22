#!/usr/bin/env bash
# Homebrew.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Homebrew"
if command -v brew >/dev/null 2>&1; then skip "Homebrew"; exit 0; fi
run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
((DRY_RUN)) || { load_brew && ok "Homebrew"; }
