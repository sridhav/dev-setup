# zoxide: remembers the folders you cd into, so `z <part of name>` jumps there
# and sesh (Ctrl-s o in tmux) can list your projects. Prints nothing, so it's
# safe under Powerlevel10k's instant prompt.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
