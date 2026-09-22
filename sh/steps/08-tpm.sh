#!/usr/bin/env bash
# tmux plugin manager.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "tmux plugin manager"
set_aside "$HOME/.tmux/plugins"
git_clone "tpm" "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
