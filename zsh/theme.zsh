# Which Catppuccin flavour this shell should use: Latte when the OS is in light
# mode, Mocha when it is dark. Linked to ~/.config/zsh/theme.zsh and sourced
# near the top of ~/.zshrc, because the p10k flavour zstyle and the
# syntax-highlighting styles both have to be set before oh-my-zsh loads.
#
# Must stay silent: it runs under Powerlevel10k's instant prompt, which breaks
# if anything prints during startup.
#
# `make light` / `make dark` (sh/theme.sh) flip the OS appearance and write the
# cache file below. Reading that file costs nothing; asking the OS directly
# costs ~20ms a shell on macOS, so it is only the fallback.

# The repo itself, found through this file's own symlink: ~/.config/zsh/theme.zsh
# -> <repo>/zsh/theme.zsh, so :A:h is <repo>/zsh and :h again is the repo root.
# Other snippets (zsh.d/lazygit.zsh) use it to reach tracked files.
export DEV_SETUP_DIR="${${${(%):-%x}:A:h}:h}"

() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup/flavour"
  local mode=""

  [[ -r "$cache" ]] && read -r mode < "$cache"

  # No cache yet (fresh machine, or the cache was cleared): ask the OS once.
  if [[ "$mode" != light && "$mode" != dark ]]; then
    if [[ "$OSTYPE" == darwin* ]]; then
      [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]] && mode=dark || mode=light
    elif (( $+commands[gsettings] )); then
      case "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" in
        *prefer-light*) mode=light ;;
        *) mode=dark ;;
      esac
    else
      mode=dark
    fi
  fi

  export DEV_SETUP_THEME="$mode"
  [[ "$mode" == light ]] && export DEV_SETUP_FLAVOUR=latte || export DEV_SETUP_FLAVOUR=mocha
}

# The flavour *now*, rather than when this shell started. Tools that read their
# theme from the environment are launched long after startup, so `make light`
# in an already-open shell would otherwise keep giving them the old flavour.
# One file read, no fork, so it is cheap enough to call per launch.
dev_setup_flavour_now() {
  local mode=""
  [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup/flavour" ]] \
    && read -r mode < "${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup/flavour"
  [[ "$mode" == light ]] && print latte || print mocha
}
