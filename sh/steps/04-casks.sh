#!/usr/bin/env bash
# Apps and fonts (Homebrew casks listed in sh/packages.sh).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Apps and fonts"
installed="$(brew list --cask -1 2>/dev/null || true)"
for c in "${CASKS[@]}"; do
  app="$(cask_app_path "$c")"
  if grep -qx "$c" <<<"$installed" || [[ -n "$app" && -e "$app" ]]; then skip "$c"; continue; fi
  info "installing $c"
  run brew install --cask "$c"
  ok "$c"
done

# Ghostty's config names this font; without it Ghostty silently falls back.
if ((!DRY_RUN)) && [[ ! -f "$JETBRAINS_FONT" ]]; then
  warn "JetBrainsMono Nerd Font Mono is not installed ($JETBRAINS_FONT missing)"
  exit 1
fi
