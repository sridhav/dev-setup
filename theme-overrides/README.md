# theme-overrides

Hand-chosen colours for a generated theme, applied by `sh/gen-theme.py` before
it writes anything.

`sh/gen-theme.py` synthesises Catppuccin's 26 semantic names from a Ghostty
theme's 16 ANSI colours plus foreground/background (see `THEMES.md`). It gets
the ramp close, but "close" is a judgement the maths cannot make — a bar band
that reads on one palette disappears on another. This directory is where that
judgement is recorded.

One file per **slug**, named `<slug>.conf`:

```
# theme-overrides/kanso-pearl.conf
MANTLE  = #e2e0dd   # the bar band, a touch under the terminal ground
SURFACE0 = #d1d1cf  # inline comments are fine
```

- One `NAME = #rrggbb` per line; names are the 26 in `ORDER` in
  `sh/gen-theme.py` (`BASE`, `MANTLE`, `CRUST`, `TEXT`, `SUBTEXT1`, `SUBTEXT0`,
  `OVERLAY2`–`OVERLAY0`, `SURFACE2`–`SURFACE0`, and the accents). Case does not
  matter; an unknown name or a malformed colour fails the run rather than being
  skipped quietly.
- Blank lines and `#` comments are ignored. A `#` that starts a value is a
  colour, not a comment.

Then re-run the generator and commit the six files it rewrites:

```bash
sh/gen-theme.py "Kanso Pearl" kanso-pearl
```

The six generated files stay generated — which is the point. Re-running the
generator **re-applies** the overrides instead of discarding them, so a theme
can be tuned by hand without any file becoming hand-owned (AGENTS.md rule 8),
and the diff shows only the lines actually chosen.

Overrides are applied after the generator's contrast pass, so a colour named
here is used exactly as written and is **not** darkened to clear the 6:1 floor
against `SURFACE0`. Check it yourself if it is an accent.
