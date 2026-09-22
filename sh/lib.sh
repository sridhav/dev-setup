# shellcheck shell=bash
# Shared settings and helpers. Every script sources this first:
#   . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"   (from steps/)
#
# Flags work on any script: --dry-run, --force. sh/install.sh exports them
# (and BACKUP_DIR) so every step in one run shares the same settings.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$DOTFILES/sh"
export BACKUP_DIR="${BACKUP_DIR:-$HOME/.dev-setup-backup/$(date +%Y%m%d-%H%M%S)}"
export DRY_RUN="${DRY_RUN:-0}"
export FORCE="${FORCE:-0}"
DEFAULT_BRANCH="main"

parse_flags() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=1 ;;
      --force) FORCE=1 ;;
      *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
  done
}

# shellcheck source=packages.sh
. "$SCRIPTS/packages.sh"

# ------------------------------------------------------------------ config ---
# Where each cask lands, so apps installed outside Homebrew aren't reinstalled.
cask_app_path() {
  case "$1" in
    ghostty) echo "/Applications/Ghostty.app" ;;
    libreoffice) echo "/Applications/LibreOffice.app" ;;
    # Fonts count as present if installed by hand, not just via Homebrew.
    font-jetbrains-mono-nerd-font) echo "$JETBRAINS_FONT" ;;
    *) echo "" ;;
  esac
}

OMZ_PLUGINS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
  "catppuccin-powerlevel10k-themes|https://github.com/tolkonepiu/catppuccin-powerlevel10k-themes"
)
OMZ_THEMES=(
  "powerlevel10k|https://github.com/romkatv/powerlevel10k.git"
)
# Ghostty's font-family is "JetBrainsMono Nerd Font Mono"; this is one of its files.
JETBRAINS_FONT="$HOME/Library/Fonts/JetBrainsMonoNerdFontMono-Regular.ttf"
NVM_VERSION="v0.40.4"
NODE_VERSION="24"

# repo path -> target path
LINKS=(
  "zsh/zshrc|$HOME/.zshrc"
  "zsh/p10k.zsh|$HOME/.p10k.zsh"
  "zsh/catppuccin-syntax-highlighting.zsh|$HOME/.config/zsh/catppuccin-syntax-highlighting.zsh"
  "zsh/zsh.d/brew.zsh|$HOME/.zsh.d/brew.zsh"
  "zsh/zsh.d/history.zsh|$HOME/.zsh.d/history.zsh"
  "zsh/zsh.d/path.zsh|$HOME/.zsh.d/path.zsh"
  "zsh/zsh.d/tmux.zsh|$HOME/.zsh.d/tmux.zsh"
  "zsh/zsh.d/dev-setup.zsh|$HOME/.zsh.d/dev-setup.zsh"
  "ghostty/config|$HOME/.config/ghostty/config"
  "nvim|$HOME/.config/nvim"
  "tmux/tmux.conf|$HOME/.tmux.conf"
  "lazygit/config.yml|$HOME/Library/Application Support/lazygit/config.yml"
)

# Everything backup.sh copies. Symlinks are followed, so the backup holds real
# file contents, not links into this repo. ~/.zsh.d includes machine-only
# secrets, hence the 700 permissions on backups.
BACKUP_PATHS=(
  "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.zsh.d"
  "$HOME/.p10k.zsh" "$HOME/.p10k-rainbow-catppuccin-mocha.zsh" "$HOME/.config/zsh"
  "$HOME/.oh-my-zsh/custom"
  "$HOME/.config/ghostty" "$HOME/.config/nvim"
  "$HOME/.tmux.conf"
  "$HOME/Library/Application Support/lazygit/config.yml"
  "$HOME/.gitconfig" "$HOME/.config/git"
)

# ----------------------------------------------------------------- helpers ---
# Step title, numbered from the script's filename (07-omz-plugins.sh → [07]).
step() {
  local num
  num="$(basename "$0")"
  num="${num%%-*}"
  [[ "$num" =~ ^[0-9]+$ ]] || num="•"
  printf '\n\033[1;35m[%s] %s\033[0m\n' "$num" "$*"
}
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
skip() { printf '  \033[90m• %s (already present)\033[0m\n' "$*"; }
info() { printf '  \033[34m→\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
run()  { if ((DRY_RUN)); then info "would run: $*"; else "$@"; fi; }

# Each script runs in its own process, so put Homebrew on PATH here.
load_brew() {
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$b" ]]; then eval "$("$b" shellenv)"; return 0; fi
  done
  return 1
}
load_brew || true

# --force: move an existing install out of the way (into the backup) so the
# step installs fresh.
set_aside() { # path
  if ((FORCE)) && [[ -e "$1" || -L "$1" ]]; then
    local dest="$BACKUP_DIR/replaced/${1#"$HOME"/}"
    info "moving $1 → $dest"
    run mkdir -p "$(dirname "$dest")"
    run mv "$1" "$dest"
  fi
}

git_clone() { # name url dest
  set_aside "$3"
  if [[ -d "$3" ]]; then skip "$1"; return; fi
  info "cloning $1"
  run git clone --depth=1 "$2" "$3"
  ok "$1"
}
