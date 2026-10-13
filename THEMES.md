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
| **slug** | The one theme a mode+profile resolves to: `latte`, `mocha`, `ncf-light`, `kanso-pearl`, `kanagawa-dragon`. | every per-theme filename |

The three profiles:

| Profile | Light | Dark |
| --- | --- | --- |
| `catppuccin` | Catppuccin Latte (`latte`) | Catppuccin Mocha (`mocha`) |
| `scleral` | No Clown Fiesta Light (`ncf-light`) | Kanagawa Dragon (`kanagawa-dragon`) |
| `kanso-scleral` | Kanso Pearl (`kanso-pearl`) | Kanagawa Dragon (`kanagawa-dragon`) |

The two scleral profiles differ only in the light half, which is the half that
scatters: No Clown Fiesta Light is the most desaturated of the 463 Ghostty
ships, Kanso Pearl the warmer of the two. They share Kanagawa Dragon for dark,
so `kanagawa-dragon`'s six files serve both.

### One background, three programs

Ghostty paints the window, tmux paints its bar over the top of it, and Neovim
paints the pane. All three use the theme's **`base`** — Ghostty because that is
its theme's `background`, tmux through `@thm_base`, Neovim as its `Normal`
background — and `sh/gen-theme.py` derives `@thm_base` from that same Ghostty
`background`, so they agree by construction under every profile and need no
per-theme upkeep.

The tmux bar is the part that has to be kept honest about this. It draws rounded
bubbles (`@thm_surface_0`, `@thm_green`, `@thm_pink`) and the cells *between*
the bubbles are bar, not bubble. Those were `@thm_mantle` — Catppuccin's look, a
band a whisker under the page — which is 6 levels on a pale theme (`#ecebea`
against `#f2f1ef` on Kanso Pearl): too little to read as a deliberate band, and
enough to read as tmux and the terminal disagreeing. Every non-bubble `bg=` in
`status-style`, `window-status-format`, `window-status-current-format` and
`status-right` is `@thm_base` for that reason, and so is the dotted rule on
`status-format[1]`. The bubbles are untouched; they float on the page instead of
on a strip of their own.

Neovim's bars are a separate decision and deliberately still sit on `mantle`:
they are drawn *inside* the pane, over a background Neovim itself painted, so
there is no second program to disagree with.

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
make theme                 # what is active now: mode · profile · slug
make light                 # light, keeping the current profile
make dark                  # dark, keeping the current profile

make catppuccin            # switch profile, keeping the current mode
make scleral
make kanso-scleral

make light-catppuccin      # both at once
make dark-catppuccin
make light-scleral
make dark-scleral
make light-kanso-scleral
make dark-kanso-scleral

make light profile=scleral # same as `make light-scleral`
```

`make light --scleral` is **not** valid — make claims the flag itself, which is
what the `profile=<name>` variable and the paired targets are for.

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

The most likely job: `kanso-scleral` stays the profile, but Kanso Pearl and
Kanagawa Dragon are replaced by a different pair (or just one of them). Nothing
about the machinery changes — only the row that says what the names are, and the
files named after the slugs.

Worked example: `kanso-scleral` becomes **Rosé Pine Dawn** (light) + **Rosé
Pine** (dark), slugs `rose-pine-dawn` and `rose-pine`.

A slug shared by two profiles is shared on purpose — `kanagawa-dragon` is the
dark half of both `scleral` and `kanso-scleral`, and its six files serve both.
Repointing one profile at a new dark theme does not free the old slug's files
until nothing else names them.

```bash
ghostty +list-themes          # the names must match exactly, spaces and all
```

**1. `sh/lib.sh` — the row.** `name|ghostty light|ghostty dark|light slug|dark slug`:

```diff
-  "kanso-scleral|Kanso Pearl|Kanagawa Dragon|kanso-pearl|kanagawa-dragon"
+  "kanso-scleral|Rosé Pine Dawn|Rosé Pine|rose-pine-dawn|rose-pine"
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

**4. `zsh/theme.zsh` — the one row** for that profile in
`DEV_SETUP_PROFILE_SLUGS`. Everything downstream (`DEV_SETUP_SLUG`,
`DEV_SETUP_SYNTAX`, `DEV_SETUP_K9S_SKIN`, `dev_setup_slug_now()`) reads it.

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
  `case "$v" in scleral|kanso-scleral|catppuccin)` line, or the profile silently
  falls back to Catppuccin.
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

To tune a generated theme by hand, do **not** edit the six files — put the
colours in `theme-overrides/<slug>.conf` (`NAME = #rrggbb`, one per line) and
re-run the generator, which applies them before writing. Re-running then
re-applies your choices instead of discarding them, so the files stay generated
(AGENTS.md rule 8) and the diff shows only what you chose. Overrides land after
the contrast pass, so a colour named there is used exactly as written and is not
darkened to clear the 6:1 floor. See `theme-overrides/README.md`.

A Ghostty theme is 16 ANSI colours plus fg/bg; the 26 Catppuccin semantic names
(`base`/`mantle`/`crust`, `text`/`subtext*`, `overlay*`, `surface*`, and the
accents) are **synthesised** from those — greys interpolated to Catppuccin's own
luminance ratios, the hues ANSI has no slot for (lavender, sapphire, peach,
flamingo, rosewater, pink, maroon, sky) blended from their neighbours. On a light
theme every accent is then darkened until it clears **6:1 against `SURFACE0`**,
because accents ship tuned for a near-white page and the prompt and tmux bubbles
put them on a mid grey. Eyeball the result anyway.

**4. `sh/theme.sh` — the flag.** Add `--<name>) profile=<name> ;;` to the arg loop.
A flag with no mode means "switch the profile, keep the mode", which is what the
bare `make <name>` target below uses.

**5. `Makefile` — the targets.** `<name>` (profile only), `light-<name>` and
`dark-<name>`, plus all three in `.PHONY`. One line each, calling
`$(S)/theme.sh [<mode>] --<name>`; no logic here.

**6. Neovim.**
- A plugin file per colourscheme, `nvim/lua/plugins/<name>.lua`: `lazy = false`,
  `priority = 900` (under catppuccin's 1000), `opts`/`setup` only — **never apply
  the colourscheme from the plugin file**, `lua/config/theme.lua` does that.
- `nvim/lua/config/theme.lua`: a row in `SCHEMES` (the `:colorscheme` name per
  mode) and one in `SLUGS` (the slug per mode, matching `THEME_PROFILES`).
- Nothing else. The bars read `M.palette()` / `M.lualine_theme()` /
  `M.bufferline()`, which find `nvim/lua/themes/<slug>.lua` by name.
- Run `nvim --headless "+Lazy! sync" +qa` and commit `nvim/lazy-lock.json` with it.

**7. `zsh/theme.zsh` — one row.** `DEV_SETUP_PROFILE_SLUGS` is an associative
array of `profile -> "<light slug> <dark slug>"`; add a row and everything
downstream follows it — the validation (`(( ${+DEV_SETUP_PROFILE_SLUGS[$pf]} ))`),
`DEV_SETUP_SLUG`, `DEV_SETUP_SYNTAX` and `DEV_SETUP_K9S_SKIN` (Catppuccin's
files carry a `catppuccin-` prefix, generated ones are bare slugs), and
`dev_setup_slug_now()` / `dev_setup_skin_now()`, which the tool wrappers call
long after the shell started.

The helpers answer in `$REPLY` rather than on stdout. That is deliberate: this
file runs under Powerlevel10k's instant prompt and `x="$(f)"` would fork a
subshell per call for what is a string slice. Only the `_now` wrappers print.

The Powerlevel10k style is the one thing still keyed off the profile *name*
rather than the table: Catppuccin gets `rainbow`, everything else `classic`
(step 8).

**8. Pick the prompt style.** `DEV_SETUP_P10K_STYLE` is `rainbow` or `classic`:
- **rainbow** gives every segment its own accent *background* with crust text.
  It needs saturated accents; Catppuccin has them.
- **classic** puts the accents on as *text* over one `SURFACE0` background. That
  is what a quiet, desaturated palette wants — a washed-out accent makes a murky
  background but reads fine as text at 6:1.

**9. Docs.** `AGENTS.md`'s layout table and `README.md`'s command list.

## Four traps

These are the ways this has actually broken. All four look harmless in a diff.

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

**In a tmux `status-format`, `bg=default` is not the terminal's background.**
It means "this status line's own default style", which is `status-style` — the
mantle the bar is drawn on. The dotted rule on `status-format[1]` was written
with `bg=default` meaning "the pane's ground" and got the bar's band instead, so
the bar rendered two rows tall with a line of dots through it rather than a bar
with a gap under it. Name the colour — `bg=#{@thm_base}`, or the shell
substitution `status-format[1]` uses, because `#{client_width}` has to survive
to draw time.

Reading the option back does **not** catch this: `show -gv` returns the format
string, `bg=default` and all, which looks right. The only check that sees what
was painted is the wire. Attach tmux through a pty and read the SGR in front of
the row:

```bash
python3 - <<'EOF'
import os, pty, select, re, time
pid, fd = pty.fork()
if pid == 0: os.execvp("tmux", ["tmux", "-L", "check", "attach"])
buf = b""; t0 = time.time()
while time.time() - t0 < 3:
    if select.select([fd], [], [], 0.3)[0]:
        d = os.read(fd, 65536)
        if not d: break
        buf += d
d = buf.decode("utf8", "replace")
m = re.search(r"(?:\u00b7 ){3,}", d)          # the dotted row, not the prompt's
print(repr(d[m.start()-70:m.start()]))         # ...48;2;R;G;Bm just before it
EOF
```

Match what that prints against `@thm_base`. Watch out for the shell prompt's own
filler dots, which are solid `····` where this row is `· · ·` — mistaking one
for the other reports the wrong colour entirely.

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
| tmux | `@thm_*`, from catppuccin/tmux or `~/.config/tmux/theme.conf` (a symlink `theme.sh` maintains); the bar and its dotted rule sit on `@thm_base`, the same ground Ghostty and Neovim use | re-sourcing `~/.tmux.conf` |
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
pf=scleral md=light                      # every profile x mode: catppuccin,
                                         # scleral, kanso-scleral x light, dark
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
