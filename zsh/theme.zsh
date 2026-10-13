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

  # Which theme profile: catppuccin (the default) or scleral.
  local pf="" pcache="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup/profile"
  [[ -r "$pcache" ]] && read -r pf < "$pcache"
  [[ "$pf" == scleral ]] || pf=catppuccin
  export DEV_SETUP_PROFILE="$pf"

  # The slug every per-theme file is named after.
  if [[ "$pf" == scleral ]]; then
    [[ "$mode" == light ]] && DEV_SETUP_SLUG=kanso-pearl || DEV_SETUP_SLUG=kanagawa-dragon
    DEV_SETUP_SYNTAX="syntax-$DEV_SETUP_SLUG.zsh"
    DEV_SETUP_K9S_SKIN="$DEV_SETUP_SLUG"
  else
    DEV_SETUP_SLUG="$DEV_SETUP_FLAVOUR"
    DEV_SETUP_SYNTAX="catppuccin-syntax-highlighting-$DEV_SETUP_SLUG.zsh"
    DEV_SETUP_K9S_SKIN="catppuccin-$DEV_SETUP_SLUG"
  fi
  # Which Powerlevel10k style suits the palette.
  #
  # "rainbow" gives every segment its own coloured background with light text
  # on top, which needs saturated accents to read -- Catppuccin has them. The
  # scleral profile deliberately does not: its palettes are muted by design, and
  # as rainbow backgrounds their mid-tones come out murky with barely-legible
  # text. "classic" puts the accents on as *text* over one surface instead,
  # which is exactly what a quiet palette wants.
  if [[ "$pf" == scleral ]]; then
    export DEV_SETUP_P10K_STYLE=classic
  else
    export DEV_SETUP_P10K_STYLE=rainbow
  fi

  export DEV_SETUP_SLUG DEV_SETUP_SYNTAX DEV_SETUP_K9S_SKIN
}

# The flavour *now*, rather than when this shell started. Tools that read their
# theme from the environment are launched long after startup, so `make light`
# in an already-open shell would otherwise keep giving them the old flavour.
# One file read, no fork, so it is cheap enough to call per launch.
dev_setup_flavour_now() {
  local mode="" c="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup"
  [[ -r "$c/flavour" ]] && read -r mode < "$c/flavour"
  [[ "$mode" == light ]] && print latte || print mocha
}

# The active theme slug at launch time: latte/mocha, or the scleral pair.
dev_setup_slug_now() {
  local mode="" pf="" c="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup"
  [[ -r "$c/flavour" ]] && read -r mode < "$c/flavour"
  [[ -r "$c/profile" ]] && read -r pf < "$c/profile"
  if [[ "$pf" == scleral ]]; then
    [[ "$mode" == light ]] && print kanso-pearl || print kanagawa-dragon
  else
    [[ "$mode" == light ]] && print latte || print mocha
  fi
}

# The k9s skin name for that slug.
dev_setup_skin_now() {
  local s; s="$(dev_setup_slug_now)"
  case "$s" in latte|mocha) print "catppuccin-$s" ;; *) print "$s" ;; esac
}
