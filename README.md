# dev-setup

Ghostty, Neovim, oh-my-zsh + Powerlevel10k, and tmux, all in Catppuccin Mocha, set up the same way on every machine: **macOS**, **Ubuntu** and **Linux Mint** (desktop).

## New Mac

```sh
xcode-select --install            # needed for git and make; re-run after the dialog finishes
git clone git@github.com:sridhav/dev-setup.git ~/dev-setup   # any location works
cd ~/dev-setup && make install
```

## New Ubuntu / Linux Mint machine

```sh
sudo apt update && sudo apt install -y git make
git clone git@github.com:sridhav/dev-setup.git ~/dev-setup   # or https://github.com/sridhav/dev-setup.git
cd ~/dev-setup && make install
```

It asks for your password (sudo) for apt, Docker and the login shell. **Log out and back in afterwards** so zsh becomes your shell and `docker` works without sudo.

## What `make install` does

The same numbered steps in the same order on every machine. Where macOS and Linux differ, the step does the right thing for each:

| Step | macOS | Ubuntu / Linux Mint |
| --- | --- | --- |
| 01 System basics | Xcode Command Line Tools | apt: build tools, git, curl, **zsh**, clipboard (xclip, wl-clipboard), LibreOffice |
| 02 Homebrew | ✓ | ✓ (Homebrew on Linux, `/home/linuxbrew`) |
| 03 Formulae (`sh/packages.sh`) | shared list + colima/docker | shared list (same versions as the Macs) |
| 04 Apps and fonts | casks: Ghostty, JetBrains Mono Nerd Font, LibreOffice | Ghostty (.deb from ghostty-ubuntu), JetBrains Mono Nerd Font → `~/.local/share/fonts` |
| 05 MesloLGS NF font | ✓ | ✓ |
| 06 oh-my-zsh | ✓ | ✓ |
| 07 zsh plugins and themes | ✓ | ✓ |
| 08 tmux plugin manager | ✓ | ✓ |
| 09 nvm and Node 24 | ✓ | ✓ |
| 10 Link configs into `~` | ✓ | ✓ (Ghostty keybindings: `ghostty/linux.conf`) |
| 11 tmux plugins | ✓ | ✓ |
| 12 Neovim plugins (`lazy-lock.json`) | ✓ | ✓ |
| 13 zsh as login shell | ✓ | ✓ |
| 14 Docker | runs via colima (`colima start`) | Docker Engine from Docker's apt repo, service enabled, you're added to the `docker` group |

The JetBrains Mono Nerd Font is required, because the Ghostty config uses it. Step 04 fails if it's missing.

**All keys in one place:** press `<leader>k` (Space, then k) in Neovim to open `nvim/CHEATSHEET.md`, which covers Neovim, tmux and Ghostty.

**Ghostty keys:** the shared settings are in `ghostty/config`. Keybindings are per OS, in `ghostty/macos.conf` and `ghostty/linux.conf`. On Linux, Cmd becomes Ctrl+Shift, and Cmd+Shift becomes Ctrl+Shift+Alt. For example, a split is Cmd+D on a Mac and Ctrl+Shift+D on Linux.

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

| On the machine where you changed something | On every other machine |
| --- | --- |
| `make push` (or `make push msg="add lazygit"`) | `make update` |

- **New tool:** add it to `sh/packages.sh`, then `make push`. `make brew-diff` lists what this machine has that the list doesn't.
- **New zsh plugin:** add it to `plugins=(...)` in `zsh/zshrc`. If it doesn't ship with oh-my-zsh, also add `"name|git-url"` to `OMZ_PLUGINS` in `sh/lib.sh`. Step 07 stops with an error if any plugin in the zshrc isn't installed.
- **Newer versions:** `make upgrade` (brew + Neovim plugins, which rewrites `lazy-lock.json`), then `make push`.
- **Check this machine:** `make status`.

## Version control

Git is the version history, and a private GitHub repo is the copy every machine pulls from. Every commit is a version.

| Command | What it does |
| --- | --- |
| `make update` | Moves to the latest version on GitHub and applies it. Shows what's incoming. Stops without changing anything if this machine has unpushed edits, and only fast-forwards (never merges). |
| `make version` | Shows which version this machine is on and how far behind or ahead it is. |
| `make history` | Lists recent versions. |
| `make rollback to=<commit or tag>` | Puts **this machine only** back on an earlier version and re-applies it. `make update` returns it to the latest. |
| `make release` (optional `name=v1.2`) | Tags the current version, for example `v2026.09.21`, so you can roll back to a known-good point by name. |

**Update notice:** once a day, each machine quietly checks GitHub in the background (`~/.zsh.d/dev-setup.zsh`). If there are new versions, the next prompt shows `dev-setup: N update(s) available`. It never applies them by itself, because an install can add apps or ask for your password.

### First-time setup (once)

```sh
git add -A && git commit -m "initial dev setup"
gh repo create dev-setup --private --source . --push   # or add any private remote and push
```

On each other machine: `git clone <url> ~/dev-setup && cd ~/dev-setup && make install`.

## Secrets and machine-only settings

Put them in `~/.zsh.d/<name>.zsh`. The zshrc sources every `*.zsh` file there, and only the files linked by `sh/install.sh` come from this repo, so anything else stays on that machine. Never commit secrets here.

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
zsh/p10k.zsh              → ~/.p10k.zsh   (loads p10k-classic.zsh or p10k-rainbow.zsh, Catppuccin Mocha)
zsh/zsh.d/*.zsh           → ~/.zsh.d/
zsh/catppuccin-syntax-highlighting.zsh → ~/.config/zsh/
tmux/tmux.conf            → ~/.tmux.conf
lazygit/config.yml        → ~/Library/Application Support/lazygit/config.yml
```

To re-run one step, e.g. after a failed plugin clone: `sh/steps/07-omz-plugins.sh`
