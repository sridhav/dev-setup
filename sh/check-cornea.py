#!/usr/bin/env python3
"""Check the cornea profile's palettes against the targets in CORNEA.md.

    sh/check-cornea.py            # both halves; exits 1 if any target is missed

Reads the generated nvim/lua/themes/cornea-{light,dark}.lua (the 26 names every
tool is coloured from) and measures each against its page with APCA, the
contrast model behind WCAG 3. Run it after any change to
theme-overrides/cornea-*.conf and the re-run of sh/gen-theme.py that follows.
"""
import math, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ACCENTS = ["RED", "MAROON", "FLAMINGO", "YELLOW", "PEACH", "ROSEWATER", "GREEN",
           "TEAL", "SKY", "SAPPHIRE", "BLUE", "LAVENDER", "MAUVE", "PINK"]

# |Lc| ranges: (min, max). None = no limit. One row per CORNEA.md target.
TARGETS = {
    "light": {
        "page_lstar": (90, 96),
        "TEXT": (85, 95), "SUBTEXT0": (75, None), "OVERLAY2": (75, None),
        "OVERLAY0": (60, None), "accent": (75, None), "accent_surface": (60, None),
        "chroma": 0.12,
    },
    "dark": {
        "page_lstar": (8, 15),
        "TEXT": (70, 80), "SUBTEXT0": (60, None), "OVERLAY2": (50, None),
        "OVERLAY0": (40, None), "accent": (60, None), "accent_surface": (55, None),
        "chroma": 0.10,
    },
}
MAX_HUES = 6

def rgb(h):
    h = h.lstrip("#"); return [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]

def apca(text, bg):
    def y(h):
        r, g, b = [c ** 2.4 for c in rgb(h)]
        v = 0.2126729*r + 0.7151522*g + 0.0721750*b
        return v + (0.022 - v) ** 1.414 if v < 0.022 else v
    yt, yb = y(text), y(bg)
    if yb > yt:
        s = (yb ** 0.56 - yt ** 0.57) * 1.14
        return 0.0 if s < 0.1 else (s - 0.027) * 100
    s = (yb ** 0.65 - yt ** 0.62) * 1.14
    return 0.0 if s > -0.1 else (s + 0.027) * 100

def lin(c): return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def lstar(h):
    r, g, b = [lin(c) for c in rgb(h)]
    y = 0.2126*r + 0.7152*g + 0.0722*b
    return 116 * y ** (1/3) - 16 if y > 216/24389 else y * 24389/27

def chroma(h):                                   # OKLCH C
    r, g, b = [lin(c) for c in rgb(h)]
    l = (0.4122214708*r + 0.5363325363*g + 0.0514459929*b) ** (1/3)
    m = (0.2119034982*r + 0.6806995451*g + 0.1073969566*b) ** (1/3)
    s = (0.0883024619*r + 0.2817188376*g + 0.6299787005*b) ** (1/3)
    a = 1.9779984951*l - 2.4285922050*m + 0.4505937099*s
    bb = 0.0259040371*l + 0.7827717662*m - 0.8086757660*s
    return math.hypot(a, bb)

def load(slug):
    path = os.path.join(ROOT, "nvim", "lua", "themes", slug + ".lua")
    return {k.upper(): v for k, v in re.findall(r'(\w+) = "(#[0-9a-fA-F]{6})"', open(path).read())}

def check(mode):
    slug, t = "cornea-" + mode, TARGETS[mode]
    p, fails = load(slug), []
    base = p["BASE"]
    def within(label, v, lo, hi):
        ok = (lo is None or v >= lo) and (hi is None or v <= hi)
        if not ok: fails.append("%s = %.1f, want %s..%s" % (label, v, lo, hi if hi is not None else ""))
    within("page L*", lstar(base), *t["page_lstar"])
    for k in ("TEXT", "SUBTEXT0", "OVERLAY2", "OVERLAY0"):
        within("%s |Lc|" % k, abs(apca(p[k], base)), *t[k])
    for k in ACCENTS:
        within("%s |Lc| on page" % k, abs(apca(p[k], base)), *t["accent"])
        for s in ("SURFACE0", "SURFACE1"):        # prompt/tmux bubbles, selection
            within("%s |Lc| on %s" % (k, s), abs(apca(p[k], p[s])), *t["accent_surface"])
        within("%s chroma" % k, chroma(p[k]), None, t["chroma"])
    hues = len({p[k].lower() for k in ACCENTS})
    if hues > MAX_HUES: fails.append("%d distinct accents, want at most %d" % (hues, MAX_HUES))
    print("%-13s text Lc %+.0f  comments Lc %+.0f  accents %d  %s" % (
        slug, apca(p["TEXT"], base), apca(p["OVERLAY2"], base), hues,
        "ok" if not fails else "FAIL"))
    for f in fails: print("  - " + f)
    return not fails

if __name__ == "__main__":
    sys.exit(0 if all([check("light"), check("dark")]) else 1)
