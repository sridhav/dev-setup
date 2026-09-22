# Neovim cheat sheet

`<leader>` = Space. Press Space and wait: which-key shows what comes next.
`<leader>k` opens this sheet. `q` or `Esc` closes it.
`<leader>fk` searches every keymap. `<leader>?` lists keys for this buffer.

## Moving around

| Key | Does |
|---|---|
| `s` + 2 chars + label | Jump anywhere on screen (flash) |
| `Ctrl-h/j/k/l` | Move between splits, neo-tree and tmux panes |
| `Ctrl-\` | Back to previous split/pane |
| `Ctrl-d` / `Ctrl-u` | Half page down / up |
| `gg` / `G` | Top / bottom of file |
| `%` | Jump to matching bracket |
| `*` | Search word under cursor |
| `Esc` | Clear search highlight |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward (after gd, search, etc.) |

## Files and search (Telescope)

| Key | Does |
|---|---|
| `Ctrl-p` or `<leader>ff` | Find file |
| `<leader>fg` | Grep the project |
| `<leader>fw` | Grep word under cursor |
| `<leader>fr` | Recent files |
| `<leader>fb` | Open buffers |
| `<leader>/` | Fuzzy search this file |
| `<leader>fh` | Search Neovim help |
| `<leader>fk` | Search all keymaps |

## File tree (neo-tree)

| Key | Does |
|---|---|
| `Ctrl-n` | Show / hide tree |
| `<leader>e` | Reveal current file in tree |
| in tree: `a` / `d` / `r` | Add / delete / rename |
| in tree: `?` | All tree keys |

## Code (LSP)

| Key | Does |
|---|---|
| `K` | Docs for symbol under cursor |
| `gd` / `gD` | Go to definition / declaration |
| `gr` | References |
| `gI` | Go to implementation |
| `<leader>ca` or `gra` | **Fixes / code actions** |
| `<leader>rn` | Rename symbol everywhere |
| `<leader>f` | Format file (also runs on save) |
| `<leader>tf` | Toggle format on save |
| `<leader>ds` / `<leader>ws` | Symbols in file / workspace |

## Errors and warnings

| Key | Does |
|---|---|
| `]d` / `[d` | Next / previous problem |
| `Ctrl-w d` | Show full message (instant) |
| `<leader>d` | Same, after a short pause |
| `<leader>xx` | All problems in project (Trouble) |
| `<leader>xX` | All problems in this file |
| `:LintInfo` | Which linters run here |

## Git

| Key | Does |
|---|---|
| `<leader>gg` | LazyGit |
| `<leader>gl` | Commits touching this file |
| `]c` / `[c` | Next / previous change |
| `<leader>hp` | Preview change |
| `<leader>hs` / `<leader>hr` | Stage / reset change (works on a selection too) |
| `<leader>hb` | Blame this line |
| `<leader>tb` | Toggle inline blame |
| `<leader>hd` | Diff file against index |

## Editing essentials

| Key | Does |
|---|---|
| `ciw` / `ci"` / `ci(` | Change word / inside quotes / inside parens |
| `dap` / `yap` | Delete / copy paragraph |
| `.` | Repeat last change |
| `u` / `Ctrl-r` | Undo / redo (undo survives restarts) |
| `gcc` / `gc` + motion | Toggle comment line / range |
| `>` / `<` (visual) | Indent / unindent selection |
| `qa` ... `q`, then `@a` | Record macro into a, replay it |
| `:%s/old/new/g` | Replace in file (live preview) |

## Markdown

`.md` files render in place (render-markdown). The cursor line shows raw text, so you can still edit it.

| Key | Does |
|---|---|
| `<leader>tm` | Toggle rendered / raw for this buffer |
| `<leader>mp` | Rendered preview in a side split |
| `gd` | Follow a link to that file or heading (marksman) |
| `<leader>ds` | Jump to a heading (outline) |
| `<leader>rn` | Rename heading and update links to it |

## Sessions

| Key | Does |
|---|---|
| `<leader>Ss` | Restore this directory's session |
| `<leader>Sl` | Restore last session |
| `<leader>SS` | Pick a session |

## Housekeeping

| Command | Does |
|---|---|
| `:Lazy` | Plugins: update, check, profile |
| `:Mason` | Installed LSPs, linters, formatters |
| `:ConformInfo` | Formatter for this file |
| `:checkhealth` | Diagnose problems |
