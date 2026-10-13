# THEMES.md

How colour works in this setup, and every place a change has to land. Read this
before switching, retheming or adding a theme — the chain is long and the parts
that break are the ones that look like they don't need touching.

## The model

Three words carry everything:

| Word | What it is | Where it lives |
| --- | --- | --- |
| **mode** | `light` or `dark`. The OS appearance is the source of truth. | `~/.cache/dev-setup/flavour` |
| **profile** | A light/dark *pair* of themes, e.g. `catppuccin` = Latte + Mocha. | `~/.cache/dev-setup/profile` |
| **slug** | The one theme a mode+profile resolves to: `latte`, `mocha`, `kanso-pearl`, `kanagawa-dragon`. | every per-theme filename |

`THEME_PROFILES` in `sh/lib.sh` is the table that maps the first two to the
third. **Every per-theme file is named after the slug** — that naming is the
whole mechanism: nothing has to know which theme is active, it just interpolates
the slug into a path.

Why the OS appearance rather than a setting of our own: Ghostty 1.3 has no CLI
reload (only the `reload_config` keybind), but it *does* follow the OS natively
through the `light:`/`dark:` line in `ghostty/config`. So `sh/theme.sh` flips the
one signal Ghostty already watches, and everything else reads the same thing
from the cache. No tracked file is ever rewritten to switch themes — if one were,
every machine's tree would go dirty and `make update` refuses to run on a dirty
tree.

## Switching, day to day

```bash
make theme           # what is active now: mode · profile · slug
make light           # light, keeping the current profile
make dark            # dark, keeping the current profile
make light-scleral   # light + switch profile to scleral
make dark-scleral    # dark + switch profile to scleral
make light scleral=1 # same thing; `make light --scleral` is NOT valid (make eats the flag)
```

What picks the change up, and when:

| | Picks it up |
| --- | --- |
| Ghostty | immediately (follows the OS); an already-open window needs one `Cmd+Shift+,` reload when the *profile* changed, because that rewrites `~/.config/ghostty/theme.conf` |
| tmux | immediately — `theme.sh` re-sources `~/.tmux.conf` (default socket only) |
| Neovim | on `FocusGained`; both bars rebuild on `ColorScheme` |
| k9s, lazygit | next launch, even from a shell opened beforehand (the wrappers in `zsh/zsh.d` re-read the cache) |
| opencode | next launch (`"mode": "system"`, follows the terminal) |
| Claude Code | after a restart (`theme.sh` rewrites the `theme` key in `~/.claude.json`) |
| the zsh prompt | only on `exec zsh` — the palette is fixed when the shell starts |

## Swap a profile's themes for different ones

The most likely job: scleral stays the profile, but Kanso Pearl and Kanagawa
Dragon are replaced by a different pair (or just one of them). Nothing
about the machinery changes — only the row that says what the names are, and the
files named after the slugs.

Worked example: scleral becomes **Rosé Pine Dawn** (light) + **Rosé Pine**
(dark), slugs `rose-pine-dawn` and `rose-pine`.

```bash
ghostty +list-themes          # the names must match exactly, spaces and all
```

**1. `sh/lib.sh` — the row.** `name|ghostty light|ghostty dark|light slug|dark slug`:

```diff
-  "scleral|Kanso Pearl|Kanagawa Dragon|kanso-pearl|kanagawa-dragon"
+  "scleral|Rosé Pine Dawn|Rosé Pine|rose-pine-dawn|rose-pine"
```

Keep the slugs if you are only swapping which Ghostty theme they point at, and
skip steps 3–5 below. Change them, and every per-theme filename changes with
them — that is the rest of this list.

**2. Generate, once per half:**

```bash
sh/gen-theme.py "Rosé Pine Dawn" rose-pine-dawn
sh/gen-theme.py "Rosé Pine"      rose-pine
git rm zsh/p10k-palette-kanso-pearl.zsh zsh/syntax-kanso-pearl.zsh \
       tmux/theme-kanso-pearl.conf k9s/skins/kanso-pearl.yaml \
       nvim/lua/themes/kanso-pearl.lua lazygit/theme-kanso-pearl.yml
#   ... and the same six for the old dark slug
```

**3. `sh/lib.sh` — the links.** Rename the two `zsh/syntax-<slug>.zsh` and two
`k9s/skins/<slug>.yaml` entries in `LINKS` to the new slugs. New entries are not
linked until the link step runs:

```bash
sh/steps/10-link-configs.sh      # or `make install`; owner's call, not an agent's
```

Stale links to the deleted files are harmless (`sh/status.sh` lists them) but
tidy them up: `rm ~/.config/zsh/syntax-kanso-pearl.zsh` and the k9s skin.

**4. `zsh/theme.zsh` — the slug mapping, in both places:** the block that sets
`DEV_SETUP_SLUG`/`DEV_SETUP_SYNTAX`/`DEV_SETUP_K9S_SKIN`, and `dev_setup_slug_now()`.

**5. Neovim.** `SLUGS` in `nvim/lua/config/theme.lua`, `SCHEMES` next to it
(`:colorscheme` names, which are *not* the slugs — `kanagawa-dragon` is the slug
but `kanagawa` is the colourscheme), and the plugin file: add
`nvim/lua/plugins/rose-pine.lua` (`lazy = false`, `priority = 900`, setup only —
`lua/config/theme.lua` applies it), drop the one for the theme you removed, then
`nvim --headless "+Lazy! sync" +qa` and commit `nvim/lazy-lock.json`.

**6. Reconsider the prompt style** (step 8 of the next section): a saturated pair
wants `rainbow`, a quiet one wants `classic`.

**7. Run the checks at the bottom**, then `make push`.

Changing Catppuccin itself is different: **its files are hand-made and stay that
way** (`zsh/p10k-palette-{latte,mocha}.zsh`, `zsh/catppuccin-syntax-highlighting-*.zsh`,
`k9s/skins/catppuccin-*.yaml`, `lazygit/config.yml` + `theme-latte.yml`, and
tmux's colours, which come from the plugin). Edit those by hand; never point
`gen-theme.py` at a Catppuccin theme.

## Add a theme profile

In order. Anything later depends on something earlier.

**1. Pick the pair.** `ghostty +list-themes` previews all 463. Judge both halves
in the terminal before going further — the generator can fix contrast, not taste.
Pick a slug per theme: lowercase, hyphenated, short (`kanso-pearl`).

**2. `sh/lib.sh` — the profile itself.**
- A row in `THEME_PROFILES`: `"<name>|<ghostty light>|<ghostty dark>|<light slug>|<dark slug>"`.
- `theme_profile()` validates against a literal list: add the name to its
  `case "$v" in scleral|catppuccin)` line, or the profile silently falls back to
  Catppuccin.
- `LINKS`: one `zsh/syntax-<slug>.zsh|$HOME/.config/zsh/syntax-<slug>.zsh` and one
  `k9s/skins/<slug>.yaml|$K9S_CONFIG_DIR/skins/<slug>.yaml` **per slug** (two of
  each for a profile). The other generated files are read from the repo through
  `$DEV_SETUP_DIR` and need no link.

**3. Generate the colours.** Once per theme, committing what it writes:

```bash
sh/gen-theme.py "<ghostty theme>" <slug>
```

Six files per theme: `zsh/p10k-palette-<slug>.zsh`, `tmux/theme-<slug>.conf`,
`zsh/syntax-<slug>.zsh`, `k9s/skins/<slug>.yaml`, `nvim/lua/themes/<slug>.lua`,
`lazygit/theme-<slug>.yml`.

A Ghostty theme is 16 ANSI colours plus fg/bg; the 26 Catppuccin semantic names
(`base`/`mantle`/`crust`, `text`/`subtext*`, `overlay*`, `surface*`, and the
accents) are **synthesised** from those — greys interpolated to Catppuccin's own
luminance ratios, the hues ANSI has no slot for (lavender, sapphire, peach,
flamingo, rosewater, pink, maroon, sky) blended from their neighbours. On a light
theme every accent is then darkened until it clears **6:1 against `SURFACE0`**,
because accents ship tuned for a near-white page and the prompt and tmux bubbles
put them on a mid grey. Eyeball the result anyway.

**4. `sh/theme.sh` — the flag.** Add `--<name>) profile=<name> ;;` to the arg loop.

**5. `Makefile` — the targets.** `light-<name>` and `dark-<name>`, plus both in
`.PHONY`. One line each, calling `$(S)/theme.sh <mode> --<name>`; no logic here.

**6. Neovim.**
- A plugin file per colourscheme, `nvim/lua/plugins/<name>.lua`: `lazy = false`,
  `priority = 900` (under catppuccin's 1000), `opts`/`setup` only — **never apply
  the colourscheme from the plugin file**, `lua/config/theme.lua` does that.
- `nvim/lua/config/theme.lua`: a row in `SCHEMES` (the `:colorscheme` name per
  mode) and one in `SLUGS` (the slug per mode, matching `THEME_PROFILES`).
- Nothing else. The bars read `M.palette()` / `M.lualine_theme()` /
  `M.bufferline()`, which find `nvim/lua/themes/<slug>.lua` by name.
- Run `nvim --headless "+Lazy! sync" +qa` and commit `nvim/lazy-lock.json` with it.

**7. `zsh/theme.zsh` — four places, all keyed off the profile name.** Keep them
in step or the shell and Neovim will disagree:
- the validation (`[[ "$pf" == scleral ]] || pf=catppuccin`),
- the slug mapping, which also sets `DEV_SETUP_SYNTAX` and `DEV_SETUP_K9S_SKIN`
  (Catppuccin's files carry a `catppuccin-` prefix, generated ones are bare slugs),
- the Powerlevel10k style (below),
- `dev_setup_slug_now()`, which repeats the mapping for the tool wrappers —
  it must, because it runs long after the shell started.

**8. Pick the prompt style.** `DEV_SETUP_P10K_STYLE` is `rainbow` or `classic`:
- **rainbow** gives every segment its own accent *background* with crust text.
  It needs saturated accents; Catppuccin has them.
- **classic** puts the accents on as *text* over one `SURFACE0` background. That
  is what a quiet, desaturated palette wants — a washed-out accent makes a murky
  background but reads fine as text at 6:1.

**9. Docs.** `AGENTS.md`'s layout table and `README.md`'s command list.

## Three traps

These are the ways this has actually broken. All three look harmless in a diff.

**Never write a hex into a config.** Prompt styles name colours only through
`$P10K_COLOR_*`, the tmux bar only through `#{@thm_*}`, Neovim only through
`require("config.theme").palette()`. A hardcoded Mocha hex renders fine under
Catppuccin and invisibly everywhere else — a Mocha mauve branch name on the
scleral light surface measured **1.14:1**. Two whole prompt styles and both
Neovim bars had this.

**In tmux, `set -gF` expands now; `set -g` expands at draw time.** The profile's
`@thm_*` file must be sourced *after* tpm (catppuccin sets those names as it
loads) and *before* any `-F` line reads them. Source it later and the lazy lines
look right while `status-style` keeps Catppuccin's — which is exactly how the bar
ended up a near-white band over a different background.

**`vim.o.background` is not trustworthy.** A colourscheme is free to leave it
wrong, and one this profile carried did: no-clown-fiesta's light variant applied
light colours with `background` still on `dark`. It cannot be corrected after
the fact either — setting `background` once a colourscheme is loaded resets
every highlight to Neovim's built-in defaults. So nothing in this setup
may key off it — not the palette, not lualine's `theme = "auto"` (its fallback is
chosen by that flag, which is why the bar went black), not a plugin's own
shading. The cache is the source of truth inside Neovim too. Anything that
computes highlights once must also rebuild them on `ColorScheme`, or an open
Neovim keeps the colours it started with.

## Where each tool gets its colour

| Tool | Reads | Switched by |
| --- | --- | --- |
| Ghostty | `~/.config/ghostty/theme.conf` (untracked, `config-file = ?theme.conf` at the end of the tracked config) | the OS appearance; `theme.sh` writes the override |
| zsh prompt | `zsh/p10k-palette-<slug>.zsh` → `zsh/p10k-{classic,rainbow}.zsh` | `$DEV_SETUP_SLUG` at shell start |
| zsh syntax highlighting | `$DEV_SETUP_SYNTAX` → `~/.config/zsh/<that file>` | sourced by the zshrc before oh-my-zsh |
| tmux | `@thm_*`, from catppuccin/tmux or `~/.config/tmux/theme.conf` (a symlink `theme.sh` maintains) | re-sourcing `~/.tmux.conf` |
| Neovim | `nvim/lua/config/theme.lua` → the colourscheme + `nvim/lua/themes/<slug>.lua` | `FocusGained`, then `ColorScheme` for the bars |
| lazygit | `config.yml` (Mocha) + `theme-<slug>.yml` layered through `$LG_CONFIG_FILE` | the `lazygit` wrapper, per launch |
| k9s | `$K9S_SKIN` → `skins/<skin>.yaml` | the `k9s` wrapper, per launch |
| opencode | `opencode/tui.json`, `"mode": "system"` | follows the terminal, nothing to do |
| Claude Code | the `theme` key in `~/.claude.json` | `theme.sh` rewrites it atomically |

## Verify

From the repo root. All of it must pass before committing a theme change.

```bash
for f in sh/*.sh sh/steps/*.sh; do bash -n "$f" || echo "SYNTAX: $f"; done
sh/install.sh --dry-run
sh/status.sh
ghostty +validate-config --config-file=ghostty/config
```

The prompt, in a throwaway `HOME` — never the real one — once per profile+mode.
It must print `ok`, with no errors and no "plugin not found":

```bash
pf=scleral md=light                      # repeat for every combination
T=$(mktemp -d); mkdir -p "$T/.config/zsh" "$T/.zsh.d" "$T/.cache/dev-setup"
echo $md > "$T/.cache/dev-setup/flavour"; echo $pf > "$T/.cache/dev-setup/profile"
ln -s "$PWD/zsh/zshrc" "$T/.zshrc"; ln -s "$PWD/zsh/p10k.zsh" "$T/.p10k.zsh"
for f in zsh/catppuccin-syntax-highlighting-*.zsh zsh/syntax-*.zsh zsh/theme.zsh; do
  ln -s "$PWD/$f" "$T/.config/zsh/"; done
ln -s ~/.oh-my-zsh "$T/.oh-my-zsh"; cp zsh/zsh.d/*.zsh "$T/.zsh.d/"
HOME=$T ZDOTDIR=$T XDG_CACHE_HOME="$T/.cache" zsh -i -c '
  VCS_STATUS_LOCAL_BRANCH=main VCS_STATUS_NUM_UNSTAGED=2
  : $(( my_git_formatter(1) ))
  print -r -- "ok slug=$DEV_SETUP_SLUG style=$DEV_SETUP_P10K_STYLE git=[$my_git_format]"'
rm -rf "$T"
```

Every colour in that `git=[...]` must come from the slug's palette. A `#cba6f7`
under a non-Catppuccin slug means a hardcoded hex has crept back in.

tmux, on a throwaway socket — `status-style` must match `@thm_mantle`, not
Catppuccin's:

```bash
T=$(mktemp -d)/c; mkdir -p "$T/dev-setup"; echo light > "$T/dev-setup/flavour"
XDG_CACHE_HOME=$T tmux -L themetest -f tmux/tmux.conf new-session -d
XDG_CACHE_HOME=$T tmux -L themetest show -gv status-style
XDG_CACHE_HOME=$T tmux -L themetest show -gv @thm_mantle
XDG_CACHE_HOME=$T tmux -L themetest kill-server
```

Neovim's bars, including a live switch. Every background below must belong to the
expected slug, and the two bars must sit on the same `mantle` as `StatusLine`:

```bash
C=$(mktemp -d); mkdir -p "$C/dev-setup"
echo light > "$C/dev-setup/flavour"; echo <profile> > "$C/dev-setup/profile"
XDG_CACHE_HOME=$C nvim --headless -c 'doautocmd User VeryLazy' \
  -c "lua vim.defer_fn(function()
    for _,n in ipairs({'lualine_a_normal','lualine_c_normal','StatusLine',
                       'BufferLineFill','BufferLineBufferSelected'}) do
      local h = vim.api.nvim_get_hl(0, { name = n })
      print(string.format('%-26s fg=#%06x bg=#%06x', n, h.fg or 0, h.bg or 0))
    end
    vim.cmd('qa!') end, 2000)" </dev/null
```

To prove a *live* switch works, rewrite the cache files mid-session (flush the
handle: `local h = io.open(...) h:write(v) h:close()`) and call
`require('config.theme').sync()` between snapshots. All four combinations of
profile and mode must land on their own palette.

Lastly, eyeball it. Contrast maths passes things that still look wrong, which is
the reason the scleral profile exists at all.
