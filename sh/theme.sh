#!/usr/bin/env bash
# Switch the setup between Catppuccin Latte (light) and Mocha (dark).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

# usage: theme.sh [light|dark] [--dry-run]
#        theme.sh              prints the current mode and exits
#
# The OS appearance is the source of truth. Ghostty follows it natively (the
# light:/dark: theme line in ghostty/config), which matters because Ghostty 1.3
# cannot be reloaded from a script -- reload_config is only a keybind. So rather
# than rewrite anyone's config, this flips the one signal Ghostty already
# watches and every other tool reads the same thing.
mode=""
flags=()
for arg in "$@"; do
  case "$arg" in
    light|dark) mode="$arg" ;;
    *) flags+=("$arg") ;;
  esac
done
parse_flags ${flags[@]+"${flags[@]}"}

if [[ -z "$mode" ]]; then
  current="$(detect_appearance)"
  printf '%s (Catppuccin %s)\n' "$current" "$(flavour_for "$current")"
  exit 0
fi

flavour="$(flavour_for "$mode")"
step "Theme: $mode — Catppuccin ${flavour}"

# --- 1. the OS appearance, which Ghostty follows with no reload --------------
if [[ "$(detect_appearance)" == "$mode" ]]; then
  skip "OS appearance is $mode"
elif is_macos; then
  bool=false; [[ "$mode" == dark ]] && bool=true
  run osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to $bool"
  ok "OS appearance → $mode"
elif command -v gsettings >/dev/null 2>&1; then
  run gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode"
  ok "OS appearance → $mode"
else
  # A container or a bare WM: no appearance setting to flip. The cache below is
  # then the only signal, which is enough for everything but Ghostty.
  warn "no gsettings here; setting the cache only (Ghostty will not follow)"
fi

# --- 2. the cache every new shell reads -------------------------------------
if ((DRY_RUN)); then
  info "would write $mode to $THEME_CACHE"
else
  mkdir -p "$(dirname "$THEME_CACHE")"
  printf '%s\n' "$mode" > "$THEME_CACHE"
  ok "cached for new shells ($THEME_CACHE)"
fi

# --- 3. what is already running ---------------------------------------------
# tmux re-reads the flavour when the config is sourced again. Only the default
# socket: a server started with `tmux -L <name>` has to be reloaded by hand.
if command -v tmux >/dev/null 2>&1 && tmux has-session 2>/dev/null; then
  run tmux source-file "$HOME/.tmux.conf"
  ok "tmux reloaded"
else
  skip "no tmux server running"
fi

# Neovim re-checks on FocusGained (nvim/lua/plugins/catppuccin.lua), so clicking
# back into a window is enough; k9s and lazygit read the env on next launch.
info "Ghostty follows the OS straight away. Neovim switches when you focus it."
info "Shells already open keep their prompt until: exec zsh"
