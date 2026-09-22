#!/usr/bin/env bash
# Xcode Command Line Tools (git, make, compilers).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then skip "Command Line Tools"; exit 0; fi
run xcode-select --install
warn "Finish the Command Line Tools installer dialog, then re-run the install."
exit 1
