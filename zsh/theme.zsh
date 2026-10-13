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

# profile -> "<light slug> <dark slug>". The one place in the shell that knows
# the mapping. sh/lib.sh (THEME_PROFILES) and nvim/lua/config/theme.lua (SLUGS)
# carry the same table; all three have to stay in step, so adding a profile is
# one row in each (THEMES.md). Defined before the block below uses it, and kept
# around afterwards because the tool wrappers need it long after startup.
typeset -gA DEV_SETUP_PROFILE_SLUGS=(
  catppuccin    "latte mocha"
  scleral       "ncf-light kanagawa-dragon"
  kanso-scleral "kanso-pearl kanagawa-dragon"
)

# These three answer in $REPLY rather than on stdout, zsh's convention for a
# function called in a hot path: the startup block below runs under the instant
# prompt, and `x="$(f)"` would fork a subshell per call for what is a string
# slice. The _now wrappers at the bottom print, because their callers are
# command substitutions in tool wrappers where one fork does not matter.

# The slug for a profile + mode. An unknown profile falls back to Catppuccin
# rather than producing an empty slug, which would name no file at all.
dev_setup_slug_for() {  # profile mode -> $REPLY
  local pair="${DEV_SETUP_PROFILE_SLUGS[$1]}"
  [[ -n "$pair" ]] || pair="${DEV_SETUP_PROFILE_SLUGS[catppuccin]}"
  [[ "$2" == light ]] && REPLY="${pair%% *}" || REPLY="${pair##* }"
}

# Catppuccin's hand-made files carry a `catppuccin-` prefix; everything
# sh/gen-theme.py writes is named after the bare slug.
dev_setup_syntax_for() {  # slug -> $REPLY
  case "$1" in
    latte|mocha) REPLY="catppuccin-syntax-highlighting-$1.zsh" ;;
    *)           REPLY="syntax-$1.zsh" ;;
  esac
}
dev_setup_skin_for() {  # slug -> $REPLY
  case "$1" in latte|mocha) REPLY="catppuccin-$1" ;; *) REPLY="$1" ;; esac
}

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

  # Which theme profile: catppuccin (the default), scleral or kanso-scleral.
  # Validated against the table, so an unknown name cannot reach the slug.
  local pf="" pcache="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup/profile"
  [[ -r "$pcache" ]] && read -r pf < "$pcache"
  (( ${+DEV_SETUP_PROFILE_SLUGS[$pf]} )) || pf=catppuccin
  export DEV_SETUP_PROFILE="$pf"

  # The slug every per-theme file is named after, and the two files named from
  # it. No command substitution here: see the note above the helpers.
  local REPLY=""
  dev_setup_slug_for   "$pf" "$mode";       DEV_SETUP_SLUG="$REPLY"
  dev_setup_syntax_for "$DEV_SETUP_SLUG";   DEV_SETUP_SYNTAX="$REPLY"
  dev_setup_skin_for   "$DEV_SETUP_SLUG";   DEV_SETUP_K9S_SKIN="$REPLY"

  # Which Powerlevel10k style suits the palette.
  #
  # "rainbow" gives every segment its own coloured background with light text
  # on top, which needs saturated accents to read -- Catppuccin has them. The
  # scleral profiles deliberately do not: their palettes are muted by design,
  # and as rainbow backgrounds those mid-tones come out murky with
  # barely-legible text. "classic" puts the accents on as *text* over one
  # surface instead, which is exactly what a quiet palette wants.
  if [[ "$pf" == catppuccin ]]; then
    export DEV_SETUP_P10K_STYLE=rainbow
  else
    export DEV_SETUP_P10K_STYLE=classic
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

# The active theme slug at launch time, read from the cache for the same reason.
# Goes through the same table as startup, so the two cannot drift.
dev_setup_slug_now() {
  local mode="" pf="" REPLY="" c="${XDG_CACHE_HOME:-$HOME/.cache}/dev-setup"
  [[ -r "$c/flavour" ]] && read -r mode < "$c/flavour"
  [[ -r "$c/profile" ]] && read -r pf < "$c/profile"
  dev_setup_slug_for "$pf" "$mode"
  print -r -- "$REPLY"
}

# The k9s skin name for that slug.
dev_setup_skin_now() {
  local REPLY=""
  dev_setup_skin_for "$(dev_setup_slug_now)"
  print -r -- "$REPLY"
}
