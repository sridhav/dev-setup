# AGENTS.md

Guide for AI agents working in this repo. Read it before changing anything.

## What this repo is

One dev setup shared across all of the owner's Macs: Ghostty, Neovim, oh-my-zsh + Powerlevel10k, and tmux, all themed **Catppuccin Mocha**. Each Mac clones this repo and runs `make install`. The configs are **symlinked** into `~`, so editing `~/.zshrc`, `~/.config/nvim/…` and so on edits this repo directly.

Changes reach the other Macs by git: `make push` on one Mac, `make update` on each of the others.

## Layout

| Path | Purpose |
| --- | --- |
| `sh/packages.sh` | Homebrew `FORMULAE` and `CASKS` arrays. The only package list. |
| `sh/lib.sh` | Shared settings (`OMZ_PLUGINS`, `OMZ_THEMES`, `LINKS`, `BACKUP_PATHS`, `NVM_VERSION`, `NODE_VERSION`) and helpers (`step`, `ok`, `skip`, `info`, `warn`, `run`, `set_aside`, `git_clone`). |
| `sh/install.sh` | Runs `sh/steps/[0-9][0-9]-*.sh` in filename order. Flags: `--dry-run`, `--force`. |
| `sh/steps/NN-name.sh` | One install step per file. Each one can run on its own. |
| `sh/{update,plugins,upgrade,push,backup,status,brew-diff}.sh` | The day-to-day commands. |
| `sh/{version,history,rollback,release}.sh` | Version control: git is the history and GitHub `origin/main` is the latest. `update.sh` refuses to run on a dirty tree and only fast-forwards. |
| `zsh/zsh.d/dev-setup.zsh` | Daily background `git fetch`; shows "N update(s) available" after the first prompt. Must never print during shell startup (Powerlevel10k instant prompt) and must never apply updates itself. |
| `Makefile` | One-line wrappers around `sh/`. No logic lives here. |
| `zsh/zshrc` → `~/.zshrc` | `plugins=(...)` here is the **source of truth** for zsh plugins. |
| `zsh/p10k.zsh` → `~/.p10k.zsh` | Prompt: Rainbow Catppuccin Mocha. |
| `zsh/zsh.d/*.zsh` → `~/.zsh.d/` | Shell snippets, sourced by the zshrc via a glob. |
| `zsh/catppuccin-syntax-highlighting.zsh` → `~/.config/zsh/` | zsh-syntax-highlighting colors. Must load *before* oh-my-zsh. |
| `ghostty/config` → `~/.config/ghostty/config` | Ghostty terminal. **Requires the JetBrainsMono Nerd Font Mono font** (cask `font-jetbrains-mono-nerd-font`); step 04 fails if it's missing. Check with `ghostty +validate-config --config-file=ghostty/config`. |
| `nvim/` → `~/.config/nvim` | Neovim (lazy.nvim). `nvim/lazy-lock.json` pins plugin versions for every Mac. `nvim/CHEATSHEET.md` is the keymap cheat sheet opened by `<leader>k`, so update it when you change a keymap. External tools the plugins need (`lazygit`, `ripgrep`, `tree-sitter-cli`) go in `sh/packages.sh`. |
| `tmux/tmux.conf` → `~/.tmux.conf` | tmux + tpm. Its `set -g @plugin` lines are the source of truth for tmux plugins; step 11 installs any that are missing. |
| `lazygit/config.yml` → `~/Library/Application Support/lazygit/config.yml` | lazygit, Catppuccin Mocha (blue accent). Used by Neovim's `<leader>gg`. |

## Rules (don't break these)

1. **Never commit secrets.** No passwords, tokens, keys, hostnames tied to credentials, or files from `~/.zsh.d/` that aren't already in `zsh/zsh.d/`. Machine-only settings stay as unlinked files in `~/.zsh.d/` on that Mac. Before every commit, check the staged diff for anything secret-looking.
2. **No git identity.** `~/.gitconfig` is deliberately not managed, because each Mac uses a different git user. Don't add it back.
3. **Idempotent.** Every step checks first and prints `skip` if the thing already exists. A re-run must change nothing. Only `--force` reinstalls, and it must `set_aside` (back up) before replacing.
4. **Fixed order.** Steps run by their numeric prefix. A new step gets a number that puts it where it belongs, and anything it depends on must run in an earlier step. For example, brew is 02, so anything using `brew` goes after it.
5. **Dry-run safe.** Anything that changes the system goes through `run …`, so `--dry-run` changes nothing.
6. **macOS bash 3.2.** Scripts run under `/bin/bash` 3.2: no associative arrays, no `mapfile`, no `${var,,}`. Each step script starts with:
   ```bash
   #!/usr/bin/env bash
   # <one-line description>
   . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
   parse_flags "$@"
   ```
   (Top-level scripts in `sh/` use `/lib.sh` instead of `/../lib.sh`.)
7. **Catppuccin Mocha everywhere.** Any new tool gets Mocha colors (the official `catppuccin/<tool>` port, if one exists).
8. **Single source of truth.** Packages only in `sh/packages.sh`. Plugins, links and versions only in `sh/lib.sh`. Don't copy these lists into the Makefile, README, or other scripts; read them from those files.

## Common tasks

**Add a Homebrew package or app**
- Add it to `FORMULAE` or `CASKS` in `sh/packages.sh`.
- If a cask's app might already be installed outside Homebrew, add its `/Applications/…` path to `cask_app_path` in `sh/lib.sh` so it isn't reinstalled.
- `sh/brew-diff.sh` lists what's on this Mac but missing from the list.

**Add a zsh plugin**
- Add its name to `plugins=(...)` in `zsh/zshrc`.
- If it doesn't ship with oh-my-zsh (check `~/.oh-my-zsh/plugins/<name>`), add `"name|git-url"` to `OMZ_PLUGINS` in `sh/lib.sh`.
- Step 07 fails if any plugin in the zshrc isn't installed.

**Add or change a config file that should be synced**
- Put it in the repo, then add `"repo/path|$HOME/target"` to `LINKS` in `sh/lib.sh`.
- Also add the target to `BACKUP_PATHS` so force installs back it up.
- For a new shell snippet, add `zsh/zsh.d/<name>.zsh` and its `LINKS` entry. The zshrc sources everything in `~/.zsh.d/` automatically.

**Add a Neovim plugin**
- Add `nvim/lua/plugins/<name>.lua` (lazy.nvim spec).
- If it needs a command-line tool, add that tool to `sh/packages.sh`. If it adds keymaps, add them to `nvim/CHEATSHEET.md`.
- Run `nvim --headless "+Lazy! sync" +qa` so `nvim/lazy-lock.json` records the version, and commit the lockfile with it.

**Add a tmux plugin**
- Add `set -g @plugin 'owner/name'` to `tmux/tmux.conf`. Step 11 installs it on every Mac.

**Add an install step**
- Create `sh/steps/NN-name.sh` using the header in rule 6 and make it executable (`chmod +x`).
- Use `skip`/`run`/`ok`, and call `set_aside <path>` before the existence check if `--force` should reinstall it.
- Update the step list in `README.md`.

**Change the prompt**
- `zsh/p10k.zsh` is the catppuccin-powerlevel10k-themes rainbow-mocha file.
- The `zstyle ':catppuccin:p10k'` lines in `zsh/zshrc` must stay *above* `source $ZSH/oh-my-zsh.sh`, because the plugin reads them while oh-my-zsh loads.

## Verify before committing

Run these from the repo root. All must pass.

```bash
for f in sh/*.sh sh/steps/*.sh; do bash -n "$f" || echo "SYNTAX: $f"; done
sh/install.sh --dry-run         # every step runs in order, nothing changes
sh/status.sh               # shows unlinked configs (expected on Macs not yet installed)
sh/steps/07-omz-plugins.sh # exits 0 = every zshrc plugin is installed
```

If you changed anything under `zsh/`, check it loads cleanly in a throwaway `HOME` (never touch the real one for testing):

```bash
T=$(mktemp -d) && mkdir -p "$T/.config/zsh" "$T/.zsh.d" \
  && ln -s "$PWD/zsh/zshrc" "$T/.zshrc" && ln -s "$PWD/zsh/p10k.zsh" "$T/.p10k.zsh" \
  && ln -s "$PWD/zsh/catppuccin-syntax-highlighting.zsh" "$T/.config/zsh/" \
  && ln -s ~/.oh-my-zsh "$T/.oh-my-zsh" && cp zsh/zsh.d/*.zsh "$T/.zsh.d/" \
  && HOME=$T ZDOTDIR=$T zsh -i -c 'echo ok' ; rm -rf "$T"
```

Expect `ok` with no errors or "plugin not found" warnings.

## Pushing changes

```bash
git -C <repo> diff              # review everything first, secrets especially
sh/push.sh "short message" # stages all, commits, pushes; no-op if nothing changed
```

- Commit messages: short, imperative, say what changed (`add lazygit with catppuccin theme`, `bump nvim plugins`).
- `push.sh` runs `git add -A`, so make sure no stray files are in the tree first.
- Don't force-push, rewrite history, or change the remote. History is the version record every Mac relies on for `make rollback`.
- `main` must always be installable, because every Mac's `make update` applies it. Run the checks in "Verify before committing" first.
- Only tag (`sh/release.sh`) when the owner asks.
- After pushing, the owner runs `make update` on each other Mac. Don't do this for them over SSH or similar.

## Don't

- Don't run `make install` / `--force`, `chsh`, or anything outside the repo without the owner asking. Those change the live machine.
- Don't edit files under `~/.oh-my-zsh`, `~/.tmux/plugins`, or `~/.local/share/nvim`. They're installed, not owned by this repo.
- Don't delete anything in `~/.dev-setup-backup/`.
