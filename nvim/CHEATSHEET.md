# Keys cheat sheet

Every key in this setup, in one place: **Neovim**, then **tmux**, then **Ghostty** at the bottom.
`<leader>k` opens this sheet (`Ctrl-d` / `Ctrl-u` scroll it, `/` searches it). `q` or `Esc` closes it.

`<leader>` = Space. Press Space and wait: which-key shows what comes next.
`<leader>fk` searches every Neovim keymap. `<leader>?` lists keys for this buffer.

## Modes

Mode is shown bottom-left. When lost, press `Esc` (twice if needed) to get back to Normal.

| Mode | Get in | For |
|---|---|---|
| Normal | `Esc` | Moving and commands (the default) |
| Insert | `i` `a` before/after cursor, `I` `A` line start/end, `o` `O` new line below/above | Typing text |
| Visual | `v` chars, `V` lines, `Ctrl-v` block/column | Select, then `d` `y` `>` `gc` … |
| Command | `:` (commands), `/` `?` (search down/up) | `:w` save, `:q` quit, `:%s/a/b/g` replace |
| Replace | `R` (overtype), `r` + key (one char) | Overwriting text |
| Terminal | `:terminal` | A shell inside Neovim; `Esc Esc` leaves it |

Commands are verb + object: `d` delete, `c` change, `y` copy + `w` word, `iw` inner word, `i"` inside quotes, `ap` paragraph. So `ciw` = change word, `yap` = copy paragraph. `.` repeats.

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

## Scrolling (Neovim)

| Key | Does |
|---|---|
| `Ctrl-d` / `Ctrl-u` | Half page down / up |
| `Ctrl-f` / `Ctrl-b` | Full page down / up (also scrolls completion docs) |
| `Ctrl-e` / `Ctrl-y` | One line down / up, cursor stays |
| `zz` / `zt` / `zb` | Put cursor line mid / top / bottom of screen |
| `42G` or `:42` | Go to line 42 |
| Mouse wheel | Scrolls too |

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

## tmux

Prefix is **`Ctrl-s`**: press it, let go, then the key. The mouse works for everything (click panes, drag borders, wheel to scroll).

| Key | Does |
|---|---|
| `Ctrl-s c` | New window (tab) |
| `Ctrl-s n` / `p` / `0-9` | Next / previous / numbered window |
| `Ctrl-s w` / `s` | Pick a window / session from a list |
| `Ctrl-s ,` | Rename window |
| `Ctrl-s %` / `"` | Split side by side / top and bottom |
| `Ctrl-h/j/k/l` | Move between panes (and Neovim splits), no prefix |
| `Ctrl-s z` | Zoom pane full screen (again to restore) |
| `Ctrl-s x` / `&` | Close pane / window (asks first) |
| `Ctrl-s d` | Detach (session keeps running; `tmux attach` to return) |
| `Ctrl-s r` | Reload tmux config |
| `Ctrl-s ?` | List every tmux key |

**Scrolling back through output (copy mode):** vi keys, like Neovim. 50,000 lines of history per pane, and a thin scrollbar on the right while scrolled back.

| Key | Does |
|---|---|
| Mouse wheel | Scroll up (enters copy mode; scroll to bottom to leave) |
| `Ctrl-s [` | Enter copy mode (`Ctrl-s PageUp` = enter and page up) |
| `Ctrl-u` / `Ctrl-d` | Half page up / down |
| `k` / `j`, `Ctrl-b` / `Ctrl-f` | Line / full page |
| `g` / `G` | Top / bottom of history |
| `/` / `?` then `n` / `N` | Search down / up, next / previous match |
| `v`, move, `y` | Select and copy (goes to the system clipboard) |
| `q` or `Esc` | Leave copy mode |

## Ghostty

Mac and Linux differ: on Linux, `Cmd` becomes `Ctrl+Shift`, and `Cmd+Shift` becomes `Ctrl+Shift+Alt`.

| Mac | Linux | Does |
|---|---|---|
| `Cmd-t` | `Ctrl+Shift+t` | New tab |
| `Cmd-Shift-←` / `→` | `Ctrl+Shift+Alt+←` / `→` | Previous / next tab |
| `Cmd-w` | `Ctrl+Shift+w` | Close tab / split |
| `Cmd-d` | `Ctrl+Shift+d` | Split right |
| `Cmd-Shift-d` | `Ctrl+Shift+Alt+d` | Split down |
| `Cmd-Alt-arrows` | `Ctrl+Alt+arrows` | Move between splits |
| `Cmd-Shift-e` | `Ctrl+Shift+Alt+e` | Equalize splits |
| `Cmd-Shift-f` | `Ctrl+Shift+Alt+f` | Zoom split |
| `Cmd-+` / `-` / `0` | `Ctrl-+` / `-` / `0` | Font bigger / smaller / reset |
| `` Ctrl-` `` | `` Ctrl-` `` | Quick terminal drop-down (global) |
| `Cmd-Shift-,` | `Ctrl+Shift+,` | Reload Ghostty config |
| `Cmd-c` / `Cmd-v` | `Ctrl+Shift+c` / `v` | Copy / paste (selecting text also copies) |
| Trackpad / wheel | Wheel | Scroll output (25 MB history) |
