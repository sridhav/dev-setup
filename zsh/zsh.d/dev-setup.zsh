# Tells you when this dev setup has updates on the remote.
# Once a day a silent background `git fetch` counts the new commits; the count
# is shown after your next command (not on the first prompt, which would trip
# Powerlevel10k's instant-prompt warning). It never applies updates itself.

# This file is a symlink into the repo; resolve it to find the repo root.
typeset -g _DEV_SETUP_REPO=${${(%):-%x}:A:h:h:h}
typeset -g _DEV_SETUP_CACHE=$HOME/.cache/dev-setup

() {
  [[ -d $_DEV_SETUP_REPO/.git ]] || return
  mkdir -p $_DEV_SETUP_CACHE
  local stamp=$_DEV_SETUP_CACHE/last-check
  # Skip if we already checked in the last 24h.
  [[ -f $stamp && -z $(find $stamp -mmin +1440 2>/dev/null) ]] && return
  touch $stamp
  {
    GIT_TERMINAL_PROMPT=0 git -C $_DEV_SETUP_REPO fetch --quiet || return
    local n=$(git -C $_DEV_SETUP_REPO rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
    if (( ${n:-0} > 0 )); then print $n >| $_DEV_SETUP_CACHE/behind; else rm -f $_DEV_SETUP_CACHE/behind; fi
  } &>/dev/null &!
}

typeset -gi _dev_setup_prompts=0
_dev_setup_notice() {
  (( ++_dev_setup_prompts < 2 )) && return
  add-zsh-hook -d precmd _dev_setup_notice
  local f=$_DEV_SETUP_CACHE/behind
  [[ -s $f ]] && print -P "%F{#f9e2af}󰚰 dev-setup: $(<$f) update(s) available. Run: make -C $_DEV_SETUP_REPO update%f"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dev_setup_notice
