# shellcheck shell=bash
# Homebrew packages installed on every Mac. Add a name here, then run `make update`
# on each Mac (or `make brew-diff` to see what this Mac has that the list lacks).

FORMULAE=(
  neovim tmux tree-sitter-cli gh direnv
  lazygit ripgrep   # Neovim: <leader>gg (lazygit), <leader>fg (Telescope live grep)
  colima docker docker-buildx docker-compose kubernetes-cli
  libpq mkcert ollama poppler
)
CASKS=(
  ghostty
  font-jetbrains-mono-nerd-font   # required: Ghostty uses "JetBrainsMono Nerd Font Mono"
  libreoffice
)
