#!/usr/bin/env bash
# Runs every script in steps/ in order. Each step skips what's already installed.
#
#   sh/install.sh              install anything missing, link configs
#   sh/install.sh --dry-run    show what would happen, change nothing
#   sh/install.sh --force      back up all configs, then reinstall oh-my-zsh,
#                                   zsh/tmux/Neovim plugins and config links from
#                                   scratch (brew packages and Node still skip if present)
#
# A single step can be re-run on its own, e.g. sh/steps/07-omz-plugins.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

check_supported_os
((DRY_RUN)) && warn "dry run: nothing will be changed"

if ((FORCE)); then
  warn "force: oh-my-zsh, zsh/tmux/Neovim plugins, and config links will be reinstalled."
  warn "Everything is backed up to $BACKUP_DIR first."
  if ((!DRY_RUN)) && [[ -t 0 ]]; then
    read -r -p "  Continue? [y/N] " reply
    [[ "$reply" == [yY]* ]] || { echo "Aborted."; exit 1; }
  fi
  "$SCRIPTS/backup.sh"
fi

for s in "$SCRIPTS"/steps/[0-9][0-9]-*.sh; do
  "$s"
done

printf '\n\033[1;32mDone.\033[0m Open a new Ghostty window (or run: exec zsh).\n'
[[ -d "$BACKUP_DIR" ]] && printf 'Backups: %s\n' "$BACKUP_DIR"
printf 'Machine-only settings and secrets go in ~/.zsh.d/<name>.zsh. Those files are not tracked.\n'
