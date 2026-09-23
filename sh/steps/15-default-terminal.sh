#!/usr/bin/env bash
# Ghostty as the default terminal (macOS: shell-script handlers, Linux: x-terminal-emulator).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Default terminal"

# macOS has no single "default terminal" setting. The closest thing is the
# LaunchServices handler for the shell-script types, which is what opens a .sh
# or .command from Finder. duti (step 03) is the only way to set it.
GHOSTTY_BUNDLE_ID="com.mitchellh.ghostty"
SHELL_SCRIPT_UTIS="public.unix-executable public.shell-script com.apple.terminal.shell-script public.zsh-script public.csh-script"

if is_macos; then
  if [[ ! -d "$(cask_app_path ghostty)" ]]; then
    warn "Ghostty is not installed (step 04); skipping"
    exit 0
  fi
  if ! command -v duti >/dev/null 2>&1; then
    warn "duti is not installed (step 03); skipping"
    exit 0
  fi
  changed=0
  for uti in $SHELL_SCRIPT_UTIS; do
    # duti -d prints the current handler's bundle id, or fails if none is set.
    if [[ "$(duti -d "$uti" 2>/dev/null)" == "$GHOSTTY_BUNDLE_ID" ]]; then
      continue
    fi
    run duti -s "$GHOSTTY_BUNDLE_ID" "$uti" all
    info "$uti → Ghostty"
    changed=1
  done
  if ((changed)); then
    ok "Ghostty opens shell scripts"
  else
    skip "Ghostty opens shell scripts"
  fi
  exit 0
fi

# --- Linux -----------------------------------------------------------------
ghostty_bin="$(command -v ghostty || true)"
if [[ -z "$ghostty_bin" ]]; then
  warn "Ghostty is not installed (step 04); skipping"
  exit 0
fi

# Debian/Ubuntu/Mint: the x-terminal-emulator alternative is what most
# desktop tools shell out to.
if command -v update-alternatives >/dev/null 2>&1; then
  current="$(update-alternatives --query x-terminal-emulator 2>/dev/null | awk '/^Value:/ {print $2}')"
  if [[ "$current" == "$ghostty_bin" ]]; then
    skip "x-terminal-emulator"
  else
    run as_root update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ghostty_bin" 50
    run as_root update-alternatives --set x-terminal-emulator "$ghostty_bin"
    ok "x-terminal-emulator → $ghostty_bin"
  fi
else
  skip "x-terminal-emulator (update-alternatives not available)"
fi

# The desktop's own "preferred terminal". GNOME on Ubuntu, Cinnamon on Mint.
# Missing schema or no session bus (containers) is fine: just skip.
if command -v gsettings >/dev/null 2>&1; then
  # One line per schema; flatten it so the space-delimited match below works.
  schemas="$(gsettings list-schemas 2>/dev/null | tr '\n' ' ' || true)"
  for schema in org.gnome.desktop.default-applications.terminal org.cinnamon.desktop.default-applications.terminal; do
    case " $schemas " in
      *" $schema "*) ;;
      *) continue ;;
    esac
    if [[ "$(gsettings get "$schema" exec 2>/dev/null)" == "'$ghostty_bin'" ]]; then
      skip "$schema"
      continue
    fi
    if run gsettings set "$schema" exec "$ghostty_bin"; then
      ok "$schema → $ghostty_bin"
    else
      warn "could not set $schema (no session bus?)"
    fi
  done
else
  skip "desktop default terminal (gsettings not available)"
fi
