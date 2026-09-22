#!/usr/bin/env bash
# System basics: Xcode Command Line Tools on macOS; build tools, zsh, git, curl
# and clipboard helpers from apt on Ubuntu / Linux Mint.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

if is_macos; then
  step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then skip "Command Line Tools"; exit 0; fi
  run xcode-select --install
  warn "Finish the Command Line Tools installer dialog, then re-run the install."
  exit 1
fi

step "System packages (apt)"
missing=()
for p in "${APT_PACKAGES[@]}"; do
  if apt_installed "$p"; then skip "$p"; else missing+=("$p"); fi
done
((${#missing[@]})) || exit 0
info "installing ${missing[*]}"
run as_root apt-get update
run as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
ok "system packages"
