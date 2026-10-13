# ~/.p10k.zsh: loads the Catppuccin palette for the current flavour, then
# zsh/p10k-<style>.zsh, where <style> is the zstyle ':catppuccin:p10k' theme
# set in ~/.zshrc (classic or rainbow).
#
# The palette has to come first: the style files refer to $P10K_COLOR_* names
# and never to a hex value, which is what lets one palette swap recolour either
# style. $DEV_SETUP_SLUG comes from zsh/theme.zsh (make light / make dark).
#
# Don't run `p10k configure`: it would overwrite this file (it's a repo link).
_p10k_here="${${(%):-%x}:A:h}"

# The slug is the theme, not just the flavour: latte / mocha for Catppuccin,
# ncf-light / kanagawa-dragon for the scleral profile. Every profile ships the
# same 26 P10K_COLOR_* names (sh/gen-theme.py generates them), so the prompt
# keeps its exact shape and only the colours move.
_p10k_slug="${DEV_SETUP_SLUG:-${DEV_SETUP_FLAVOUR:-mocha}}"
[[ -r "$_p10k_here/p10k-palette-$_p10k_slug.zsh" ]] || _p10k_slug=mocha
source "$_p10k_here/p10k-palette-$_p10k_slug.zsh"

zstyle -s ':catppuccin:p10k' theme _p10k_style || _p10k_style=classic
[[ -r "$_p10k_here/p10k-$_p10k_style.zsh" ]] || _p10k_style=classic
source "$_p10k_here/p10k-$_p10k_style.zsh"

unset _p10k_style _p10k_slug _p10k_here
