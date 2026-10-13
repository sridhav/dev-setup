# lazygit: Catppuccin Mocha by default, Latte when the OS is in light mode.
#
# lazygit has no "skin name" setting like k9s, only config files, so the light
# flavour is layered on as a second file: $LG_CONFIG_FILE takes a comma-
# separated list and later files win key by key (the same thing `lazygit -ucf`
# does). config.yml carries the Mocha theme, so leaving the variable unset
# anywhere still gives the right dark colours.
#
# Used by Neovim's <leader>gg (snacks lazygit) too, since it inherits the env.
if [[ "$DEV_SETUP_FLAVOUR" == latte && -n "$DEV_SETUP_DIR" ]]; then
  export LG_CONFIG_FILE="$DEV_SETUP_DIR/lazygit/config.yml,$DEV_SETUP_DIR/lazygit/theme-latte.yml"
fi
