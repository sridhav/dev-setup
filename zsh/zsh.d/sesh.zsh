# sesh from the shell: Alt-s opens the same picker as Ctrl-s o in tmux, and
# also works outside tmux (it attaches to the session you pick). Defines a key
# binding only, so it prints nothing at startup.
if (( $+commands[sesh] )); then
  _sesh_picker() {
    zle -I
    sesh picker -i -d </dev/tty
    zle reset-prompt
  }
  zle -N _sesh_picker
  bindkey -M emacs '\es' _sesh_picker
  bindkey -M viins '\es' _sesh_picker
  bindkey -M vicmd '\es' _sesh_picker
fi
