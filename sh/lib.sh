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
# Not always set on Linux (containers, some sudo setups); steps rely on it.
export USER="${USER:-$(id -un)}"

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

# ---------------------------------------------------------------------- OS ---
# macOS, or Ubuntu / Linux Mint (desktop). Everything OS-specific is decided
# here so the steps only ask is_macos / is_linux.
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux) OS=linux ;;
  *) OS=unknown ;;
esac
is_macos() { [[ "$OS" == macos ]]; }
is_linux() { [[ "$OS" == linux ]]; }

check_supported_os() {
  if is_macos; then return 0; fi
  if is_linux && [[ -r /etc/os-release ]]; then
    local id like
    id="$(. /etc/os-release && echo "${ID:-}")"
    like="$(. /etc/os-release && echo "${ID_LIKE:-}")"
    if [[ "$id" == ubuntu || "$id" == linuxmint || " $like " == *" ubuntu "* ]]; then return 0; fi
  fi
  echo "Supported: macOS, Ubuntu, Linux Mint." >&2
  exit 1
}

# Run a command as root: directly if we already are, otherwise through sudo.
as_root() { if [[ "$(id -u)" == 0 ]]; then "$@"; else sudo "$@"; fi; }

apt_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }

if is_macos; then
  FONT_DIR="$HOME/Library/Fonts"
  JETBRAINS_FONT="$FONT_DIR/JetBrainsMonoNerdFontMono-Regular.ttf"
  LAZYGIT_CONFIG="$HOME/Library/Application Support/lazygit/config.yml"
  GHOSTTY_PLATFORM="ghostty/macos.conf"
else
  FONT_DIR="$HOME/.local/share/fonts"
  JETBRAINS_FONT="$FONT_DIR/JetBrainsMonoNerdFont/JetBrainsMonoNerdFontMono-Regular.ttf"
  LAZYGIT_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/config.yml"
  GHOSTTY_PLATFORM="ghostty/linux.conf"
fi

# Formulae for this OS: the shared list, plus the macOS-only ones on a Mac.
BREW_FORMULAE=("${FORMULAE[@]}")
if is_macos; then BREW_FORMULAE+=("${MACOS_FORMULAE[@]}"); fi

# ------------------------------------------------------------------ config ---
# (macOS) Where each cask lands, so apps installed outside Homebrew aren't reinstalled.
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
  "zsh/zsh.d/nvm.zsh|$HOME/.zsh.d/nvm.zsh"
  "ghostty/config|$HOME/.config/ghostty/config"
  # Keybindings etc. that differ per OS; the shared config includes platform.conf.
  "$GHOSTTY_PLATFORM|$HOME/.config/ghostty/platform.conf"
  "nvim|$HOME/.config/nvim"
  "tmux/tmux.conf|$HOME/.tmux.conf"
  "lazygit/config.yml|$LAZYGIT_CONFIG"
  "opencode/tui.json|$HOME/.config/opencode/tui.json"
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
  "$LAZYGIT_CONFIG"
  "$HOME/.config/opencode/tui.json"
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
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
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
