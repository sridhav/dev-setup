# lazygit: Catppuccin Mocha by default, Latte when the mode is light.
#
# lazygit has no "skin name" setting like k9s, only config files, so the light
# flavour is layered on as a second file: $LG_CONFIG_FILE takes a comma-
# separated list and later files win key by key (the same thing `lazygit -ucf`
# does). config.yml carries the Mocha theme, so leaving the variable unset
# anywhere still gives the right dark colours.
#
# As with k9s, the wrapper re-reads the flavour at launch so `make light` reaches
# an already-open shell; the export is what Neovim's <leader>gg (snacks lazygit)
# inherits, since that does not go through this function.
# config.yml carries Mocha, so only a non-Mocha theme needs an overlay.
if [[ -n "$DEV_SETUP_DIR" && -n "$DEV_SETUP_SLUG" && "$DEV_SETUP_SLUG" != mocha ]]; then
  export LG_CONFIG_FILE="$DEV_SETUP_DIR/lazygit/config.yml,$DEV_SETUP_DIR/lazygit/theme-$DEV_SETUP_SLUG.yml"
fi

lazygit() {
  if [[ -n "$DEV_SETUP_DIR" ]] && (( $+functions[dev_setup_slug_now] )); then
    local cfg="$DEV_SETUP_DIR/lazygit/config.yml" sl
    sl="$(dev_setup_slug_now)"
    [[ "$sl" != mocha && -r "$DEV_SETUP_DIR/lazygit/theme-$sl.yml" ]] \
      && cfg="$cfg,$DEV_SETUP_DIR/lazygit/theme-$sl.yml"
    LG_CONFIG_FILE="$cfg" command lazygit "$@"
  else
    command lazygit "$@"
  fi
}
