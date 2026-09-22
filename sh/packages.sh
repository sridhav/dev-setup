# shellcheck shell=bash
# Packages installed on every machine. Add a name here, then `make push`; other
# machines get it on `make update`. `make brew-diff` lists what this machine has
# that these lists lack.

# Homebrew formulae on macOS *and* Linux, so every machine runs the same versions
# (apt's Neovim is too old for this config, which needs 0.11+).
FORMULAE=(
  neovim tmux tree-sitter-cli gh direnv
  lazygit ripgrep   # Neovim: <leader>gg (lazygit), <leader>fg (Telescope live grep)
  kubernetes-cli libpq
)

# macOS only: Docker runs in a colima VM there. Linux gets native Docker Engine
# from Docker's apt repo instead (step 14).
MACOS_FORMULAE=(
  colima docker docker-buildx docker-compose
)

# macOS apps and fonts (Homebrew casks). On Linux, step 04 installs Ghostty and
# the font another way, and LibreOffice comes from apt.
CASKS=(
  ghostty
  font-jetbrains-mono-nerd-font   # required: Ghostty uses "JetBrainsMono Nerd Font Mono"
  libreoffice
)

# Ubuntu / Linux Mint (apt): what Homebrew, Neovim plugins (compilers, unzip,
# python venv for Mason) and the desktop need. zsh becomes the login shell.
APT_PACKAGES=(
  build-essential procps curl file git ca-certificates
  zsh unzip xz-utils fontconfig python3-venv
  xclip wl-clipboard   # Neovim's system clipboard on X11 (Mint) and Wayland (Ubuntu)
  libreoffice
)
