# ~/.p10k.zsh: loads zsh/p10k-<style>.zsh, where <style> is the
# zstyle ':catppuccin:p10k' theme set in ~/.zshrc (classic or rainbow).
# Don't run `p10k configure`: it would overwrite this file (it's a repo link).
zstyle -s ':catppuccin:p10k' theme _p10k_style || _p10k_style=classic
[[ -r "${${(%):-%x}:A:h}/p10k-$_p10k_style.zsh" ]] || _p10k_style=classic
source "${${(%):-%x}:A:h}/p10k-$_p10k_style.zsh"
unset _p10k_style
