# ~/.p10k.zsh: loads the Catppuccin palette for the current flavour, then
# zsh/p10k-<style>.zsh, where <style> is the zstyle ':catppuccin:p10k' theme
# set in ~/.zshrc (classic or rainbow).
#
# The palette has to come first: the style files refer to $P10K_COLOR_* names
# and never to a hex value, which is what lets one flavour swap recolour either
# style. $DEV_SETUP_FLAVOUR comes from zsh/theme.zsh (make light / make dark).
#
# Don't run `p10k configure`: it would overwrite this file (it's a repo link).
_p10k_here="${${(%):-%x}:A:h}"

_p10k_flavour="${DEV_SETUP_FLAVOUR:-mocha}"
[[ -r "$_p10k_here/p10k-palette-$_p10k_flavour.zsh" ]] || _p10k_flavour=mocha
source "$_p10k_here/p10k-palette-$_p10k_flavour.zsh"

zstyle -s ':catppuccin:p10k' theme _p10k_style || _p10k_style=classic
[[ -r "$_p10k_here/p10k-$_p10k_style.zsh" ]] || _p10k_style=classic
source "$_p10k_here/p10k-$_p10k_style.zsh"

unset _p10k_style _p10k_flavour _p10k_here
