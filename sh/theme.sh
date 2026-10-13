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
profile=""
flags=()
for arg in "$@"; do
  case "$arg" in
    light|dark)   mode="$arg" ;;
    --scleral)    profile=scleral ;;
    --catppuccin) profile=catppuccin ;;
    *) flags+=("$arg") ;;
  esac
done
parse_flags ${flags[@]+"${flags[@]}"}

# No profile asked for: keep whichever is already active.
[[ -n "$profile" ]] || profile="$(theme_profile)"

if [[ -z "$mode" ]]; then
  current="$(detect_appearance)"
  printf '%s · %s · %s\n' "$current" "$profile" "$(slug_for "$profile" "$current")"
  exit 0
fi

slug="$(slug_for "$profile" "$mode")"
gtheme="$(profile_field "$profile" "$([[ $mode == light ]] && echo 2 || echo 3)")"
step "Theme: $mode — $profile ($slug)"

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

# --- 2b. the profile, and Ghostty's theme override --------------------------
# ghostty/config is a tracked symlink, so the theme cannot be written into it:
# every machine's tree would go dirty and `make update` refuses that. Instead it
# ends with `config-file = ?theme.conf`, and this writes that file -- untracked,
# machine-local, and last-wins over the default in the tracked config.
if ((DRY_RUN)); then
  info "would write $profile to $THEME_PROFILE_CACHE"
  info "would set ghostty theme to: $gtheme"
else
  mkdir -p "$(dirname "$THEME_PROFILE_CACHE")"
  printf '%s\n' "$profile" > "$THEME_PROFILE_CACHE"
  mkdir -p "$HOME/.config/ghostty"
  {
    printf '# Written by sh/theme.sh -- not tracked, safe to delete.\n'
    printf '# Profile %s, %s mode.\n' "$profile" "$mode"
    printf 'theme = %s\n' "$gtheme"
  } > "$HOME/.config/ghostty/theme.conf"
  ok "profile $profile · ghostty theme $gtheme"
fi

# tmux's bar is built from catppuccin's @thm_* names, so a non-Catppuccin
# profile supplies its own set; tmux/tmux.conf sources this if it exists.
if [[ "$profile" == catppuccin ]]; then
  if ((DRY_RUN)); then info "would remove ~/.config/tmux/theme.conf"
  else rm -f "$HOME/.config/tmux/theme.conf"; fi
else
  if ((DRY_RUN)); then info "would point ~/.config/tmux/theme.conf at tmux/theme-$slug.conf"
  else
    mkdir -p "$HOME/.config/tmux"
    ln -sfn "$DOTFILES/tmux/theme-$slug.conf" "$HOME/.config/tmux/theme.conf"
    ok "tmux colours ← tmux/theme-$slug.conf"
  fi
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
# back into a window is enough. k9s and lazygit re-read the flavour as they
# launch (the wrappers in zsh/zsh.d), so they are right even from a shell that
# was already open. Only the prompt itself is fixed at shell startup.
info "Ghostty follows the OS straight away. Neovim switches when you focus it."
info "Already-open Ghostty windows need one reload: Cmd+Shift+, (theme.conf changed)"
info "k9s and lazygit are right from their next launch, in any shell."
info "Only the prompt of an already-open shell needs: exec zsh"
