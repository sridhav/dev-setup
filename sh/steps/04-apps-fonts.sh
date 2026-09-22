#!/usr/bin/env bash
# Apps and fonts: Homebrew casks on macOS; Ghostty (.deb) and the JetBrains Mono
# Nerd Font on Linux. The font is required: Ghostty's config names it.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Apps and fonts"
if is_macos; then
  installed="$(brew list --cask -1 2>/dev/null || true)"
  for c in "${CASKS[@]}"; do
    app="$(cask_app_path "$c")"
    if grep -qx "$c" <<<"$installed" || [[ -n "$app" && -e "$app" ]]; then skip "$c"; continue; fi
    info "installing $c"
    run brew install --cask "$c"
    ok "$c"
  done
else
  # Ghostty has no official Ubuntu package; ghostty-ubuntu builds .debs for
  # Ubuntu 24.04/26.04 and maps Linux Mint versions to them.
  if command -v ghostty >/dev/null 2>&1; then
    skip "ghostty"
  else
    info "installing ghostty"
    # It downloads the .deb into the current directory, so run it from a temp dir.
    run bash -c 'cd "$(mktemp -d)" && bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"'
    ok "ghostty"
  fi

  if [[ -f "$JETBRAINS_FONT" ]]; then
    skip "JetBrainsMono Nerd Font"
  else
    info "installing JetBrainsMono Nerd Font"
    dir="$(dirname "$JETBRAINS_FONT")"
    run mkdir -p "$dir"
    run bash -c "curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C '$dir'"
    run fc-cache -f "$FONT_DIR"
    ok "JetBrainsMono Nerd Font"
  fi
fi

# Ghostty's config names this font; without it Ghostty silently falls back.
if ((!DRY_RUN)) && [[ ! -f "$JETBRAINS_FONT" ]]; then
  warn "JetBrainsMono Nerd Font Mono is not installed ($JETBRAINS_FONT missing)"
  exit 1
fi
