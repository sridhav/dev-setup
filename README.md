# dev-setup

Ghostty, Neovim, oh-my-zsh + Powerlevel10k, and tmux, all in Catppuccin Mocha, set up the same way on every Mac.

## New Mac

```sh
xcode-select --install            # needed for git; re-run after the dialog finishes
git clone <this-repo-url> ~/dev-setup   # any location works
cd ~/dev-setup && make install
```

`make install` runs the same numbered steps in the same order every time:

1. Xcode Command Line Tools
2. Homebrew
3. Homebrew formulae (`sh/packages.sh`)
4. Apps and fonts: Ghostty, JetBrains Mono Nerd Font (required by the Ghostty config; the step fails without it), …
5. MesloLGS NF font
6. oh-my-zsh
7. oh-my-zsh plugins and themes: powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, catppuccin-powerlevel10k-themes
8. tmux plugin manager (tpm)
9. nvm and Node 24
10. Symlink configs into `~` (anything already there is moved to `~/.dev-setup-backup/<timestamp>/`)
11. tmux plugins (catppuccin/tmux)
12. Neovim plugins, pinned by `nvim/lazy-lock.json`
13. zsh as login shell

Anything already installed is skipped, so it's safe to re-run.

## Force install and backups

```sh
make force-install   # back up, then reinstall oh-my-zsh, zsh/tmux/Neovim plugins, and config links
make backup          # only take a backup
```

Every backup goes to `~/.dev-setup-backup/<timestamp>/`, readable only by you:

- `snapshot/` holds real copies (not links) of all shell, p10k, oh-my-zsh custom, Ghostty, Neovim, tmux and git configs, including machine-only files in `~/.zsh.d`.
- `replaced/` holds the old oh-my-zsh, plugin folders and config files that the install moved aside.

Force install asks for confirmation. Brew packages and Node are still skipped if they're already installed. To restore, copy files back from `snapshot/`.

## Keeping Macs in sync

Configs are symlinked, so editing `~/.zshrc`, `~/.config/nvim/...` and so on edits the repo directly.

| On the Mac where you changed something | On every other Mac |
| --- | --- |
| `make push` (or `make push msg="add lazygit"`) | `make update` |

- **New tool:** add it to `sh/packages.sh`, then `make push`. `make brew-diff` lists what this Mac has that the list doesn't.
- **New zsh plugin:** add it to `plugins=(...)` in `zsh/zshrc`. If it doesn't ship with oh-my-zsh, also add `"name|git-url"` to `OMZ_PLUGINS` in `sh/lib.sh`. Step 07 stops with an error if any plugin in the zshrc isn't installed.
- **Newer versions:** `make upgrade` (brew + Neovim plugins, which rewrites `lazy-lock.json`), then `make push`.
- **Check this Mac:** `make status`.

## Version control

Git is the version history, and a private GitHub repo is the copy every Mac pulls from. Every commit is a version.

| Command | What it does |
| --- | --- |
| `make update` | Moves to the latest version on GitHub and applies it. Shows what's incoming. Stops without changing anything if this Mac has unpushed edits, and only fast-forwards (never merges). |
| `make version` | Shows which version this Mac is on and how far behind or ahead it is. |
| `make history` | Lists recent versions. |
| `make rollback to=<commit or tag>` | Puts **this Mac only** back on an earlier version and re-applies it. `make update` returns it to the latest. |
| `make release` (optional `name=v1.2`) | Tags the current version, for example `v2026.09.21`, so you can roll back to a known-good point by name. |

**Update notice:** once a day, each Mac quietly checks GitHub in the background (`~/.zsh.d/dev-setup.zsh`). If there are new versions, the next prompt shows `dev-setup: N update(s) available`. It never applies them by itself, because an install can add apps or ask for your password.

### First-time setup (once)

```sh
git add -A && git commit -m "initial dev setup"
gh repo create dev-setup --private --source . --push   # or add any private remote and push
```

On each other Mac: `git clone <url> ~/dev-setup && cd ~/dev-setup && make install`.

## Secrets and machine-only settings

Put them in `~/.zsh.d/<name>.zsh`. The zshrc sources every `*.zsh` file there, and only the files linked by `sh/install.sh` come from this repo, so anything else stays on that Mac. Never commit secrets here.

## Layout

```
Makefile                  one-word wrappers for the scripts in sh/
sh/
  packages.sh             brew formulae + casks
  lib.sh                  shared settings (plugins, links, backup paths) + helpers
  install.sh              runs steps/ in order (--dry-run, --force)
  steps/01-…13-*.sh       one script per install step, each re-runnable alone
  update.sh               latest version from git + install + plugins   (make update)
  plugins.sh              sync oh-my-zsh, zsh/tmux/Neovim plugins
  upgrade.sh              newer brew + Neovim plugin versions
  push.sh ["message"]     commit + push
  version.sh / history.sh / rollback.sh / release.sh   version control
  backup.sh               snapshot all configs
  status.sh               uncommitted changes + unlinked configs
  brew-diff.sh            brew packages missing from sh/packages.sh
ghostty/config            → ~/.config/ghostty/config
nvim/                     → ~/.config/nvim
zsh/zshrc                 → ~/.zshrc
zsh/p10k.zsh              → ~/.p10k.zsh   (rainbow, Catppuccin Mocha)
zsh/zsh.d/*.zsh           → ~/.zsh.d/
zsh/catppuccin-syntax-highlighting.zsh → ~/.config/zsh/
tmux/tmux.conf            → ~/.tmux.conf
lazygit/config.yml        → ~/Library/Application Support/lazygit/config.yml
```

To re-run one step, e.g. after a failed plugin clone: `sh/steps/07-omz-plugins.sh`
