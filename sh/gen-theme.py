#!/usr/bin/env python3
"""Generate the per-theme colour files from a Ghostty theme.

    sh/gen-theme.py "Kanso Pearl" kanso-pearl

Ghostty ships 463 themes as plain files holding 16 ANSI colours plus
background/foreground. The rest of this setup is written against Catppuccin's
26 semantic names (base/mantle/crust, text/subtext, overlay, surface, accents),
which no other theme publishes -- so the ramp is synthesised here: the greys by
interpolating background toward foreground, the accents mapped from ANSI with
the Catppuccin-only hues (lavender, sapphire, peach...) blended from their
nearest ANSI neighbours.

Catppuccin's own files are hand-made and stay that way; this is only for themes
added on top. Run it once per theme and commit what it writes.
"""
import os, sys, json

DIRS = ["/Applications/Ghostty.app/Contents/Resources/ghostty/themes",
        "/usr/share/ghostty/themes", "/usr/local/share/ghostty/themes"]

def load(name):
    for d in DIRS:
        p = os.path.join(d, name)
        if os.path.isfile(p):
            pal, extra = {}, {}
            for line in open(p, encoding="utf-8", errors="replace"):
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line: continue
                k, v = [x.strip() for x in line.split("=", 1)]
                if k == "palette" and "=" in v:
                    i, c = v.split("=", 1); pal[int(i)] = c.strip()
                else: extra[k] = v
            return pal, extra
    sys.exit("theme not found: " + name)

hx  = lambda t: "#%02x%02x%02x" % t
def rgb(h):
    h = h.lstrip("#")
    if len(h) == 3: h = "".join(c*2 for c in h)
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
def mix(a, b, f):
    x, y = rgb(a), rgb(b)
    return hx(tuple(max(0, min(255, round(x[i] + (y[i]-x[i])*f))) for i in range(3)))
def lum(c):
    def f(v):
        v /= 255.0
        return v/12.92 if v <= 0.03928 else ((v+0.055)/1.055)**2.4
    r, g, b = rgb(c)
    return 0.2126*f(r) + 0.7152*f(g) + 0.0722*f(b)

def at_lum(c, target):
    """The colour c moved toward black or white until it hits `target`
    luminance, keeping its hue. Blending by a fixed percentage does not work:
    5% black is a big luminance step on a mid grey and almost none on a
    near-black, which is what made the generated tmux bar a muddy band on a
    light theme and invisible on a dark one."""
    target = max(0.0, min(1.0, target))
    cur = lum(c)
    if abs(cur - target) < 1e-4: return c
    dark = target < cur
    towards = "#000000" if dark else "#ffffff"
    lo, hi = 0.0, 1.0
    for _ in range(30):
        mid = (lo + hi) / 2
        # Blending toward black lowers luminance as mid grows, toward white it
        # raises it -- so which half to keep depends on the direction.
        if (lum(mix(c, towards, mid)) > target) == dark: lo = mid
        else: hi = mid
    return mix(c, towards, (lo + hi) / 2)

def shade(c, f):                      # f<0 darker, f>0 lighter
    return mix(c, "#000000" if f < 0 else "#ffffff", abs(f))

def palette(name):
    pal, extra = load(name)
    g = lambda k, d: extra.get(k, d) if extra.get(k, "").startswith("#") else d
    bg, fg = g("background", "#1e1e2e"), g("foreground", "#cdd6f4")
    P = {i: (pal.get(i) or "#000000") for i in range(16)}
    for i in P:
        if not P[i].startswith("#"): P[i] = "#" + P[i]

    # Greys, by target luminance rather than by blend percentage.
    #
    # The tmux bar is drawn as: terminal ground (base), a bar band (mantle) and
    # raised bubbles (surface_0). What makes it read is the *ratio* between
    # those three, and Catppuccin sets the reference: on Latte the bar sits a
    # whisker under the ground and the bubbles drop well below it; on Mocha the
    # bar is invisible against the ground and the bubbles lift slightly. Match
    # those proportions instead of nudging by a fixed percentage.
    Lb = lum(bg)
    light = Lb > 0.4
    if light:                       # Latte: 0.879 -> 0.815 bar -> 0.632 bubble
        mant, crus = Lb*0.945, Lb*0.90
        s0, s1, s2 = Lb*0.72, Lb*0.60, Lb*0.50
    else:                           # Mocha: 0.0137 -> 0.0085 bar -> 0.0245 bubble
        mant, crus = Lb*0.62, Lb*0.42
        s0, s1, s2 = Lb+0.011, Lb+0.024, Lb+0.042
    c = {
      "BASE": bg, "MANTLE": at_lum(bg, mant), "CRUST": at_lum(bg, crus),
      "TEXT": fg, "SUBTEXT1": mix(fg, bg, 0.12), "SUBTEXT0": mix(fg, bg, 0.22),
      "OVERLAY2": mix(fg, bg, 0.35), "OVERLAY1": mix(fg, bg, 0.45), "OVERLAY0": mix(fg, bg, 0.55),
      "SURFACE2": at_lum(bg, s2), "SURFACE1": at_lum(bg, s1), "SURFACE0": at_lum(bg, s0),
      # accents straight off ANSI where one exists
      "RED": P[1], "GREEN": P[2], "YELLOW": P[3], "BLUE": P[4], "MAUVE": P[5], "TEAL": P[6],
      # and blended for the hues ANSI has no slot for
      "PEACH": mix(P[1], P[3], 0.55), "MAROON": mix(P[1], P[3], 0.22),
      "PINK": mix(P[5], P[1], 0.30), "FLAMINGO": mix(P[1], fg, 0.45),
      "ROSEWATER": mix(P[1], fg, 0.65), "LAVENDER": mix(P[4], P[5], 0.40),
      "SAPPHIRE": mix(P[4], P[6], 0.35), "SKY": mix(P[6], P[4], 0.25),
    }

    # On a light theme the accents arrive as mid-tone colours meant to be read
    # against a near-white page -- but the prompt and the tmux bubbles put them
    # on SURFACE0, a mid grey, where mid-on-mid is no contrast at all. (Left
    # alone, No Clown Fiesta Light gave 1.5:1 for the clock and 1.7:1 for the
    # directory: invisible. Catppuccin Latte has the same weakness at ~2.3:1;
    # Mocha escapes it only because its accents are light on a dark surface.)
    #
    # So darken each accent until it clears 4.5:1 against SURFACE0. It costs
    # some fidelity to the upstream theme and the result is a deeper, more
    # saturated-looking set -- which is how light themes are supposed to work,
    # and the trade is worth making for legibility.
    if light:
        # 6:1, not the 4.5:1 minimum. These are small glyphs -- a branch name,
        # a clock -- and at 4.5 they technically pass while still reading as
        # washed out, which is the whole problem this profile exists to avoid.
        need = (lum(c["SURFACE0"]) + 0.05) / 6.0 - 0.05
        for k in ("BLUE","LAVENDER","SAPPHIRE","SKY","TEAL","GREEN","YELLOW","PEACH",
                  "RED","MAROON","PINK","FLAMINGO","ROSEWATER","MAUVE"):
            if lum(c[k]) > need:
                c[k] = at_lum(c[k], max(need, 0.02))
        # The overlay greys are the dim-text ramp -- comments above all, which
        # sit on the terminal ground, not on a prompt segment, so they are
        # measured against BASE. Interpolating them toward the background left
        # overlay0 at 2.1:1 on a light theme: invisible. Pin them to real
        # ratios, keeping Catppuccin's ordering where overlay0 is the faintest
        # and overlay2 the strongest.
        for k, target in (("OVERLAY0", 4.8), ("OVERLAY1", 6.0), ("OVERLAY2", 7.5)):
            want = (lum(c["BASE"]) + 0.05) / target - 0.05
            if lum(c[k]) > want:
                c[k] = at_lum(c[k], max(want, 0.02))
    return c, P, bg, fg

ORDER = ["BASE","MANTLE","CRUST","TEXT","SUBTEXT1","SUBTEXT0","OVERLAY2","OVERLAY1","OVERLAY0",
         "SURFACE2","SURFACE1","SURFACE0","BLUE","LAVENDER","SAPPHIRE","SKY","TEAL","GREEN",
         "YELLOW","PEACH","RED","MAROON","PINK","FLAMINGO","ROSEWATER","MAUVE"]
TMUX = {"base":"BASE","mantle":"MANTLE","crust":"CRUST","fg":"TEXT","subtext_1":"SUBTEXT1",
        "subtext_0":"SUBTEXT0","overlay_2":"OVERLAY2","overlay_1":"OVERLAY1","overlay_0":"OVERLAY0",
        "surface_2":"SURFACE2","surface_1":"SURFACE1","surface_0":"SURFACE0","blue":"BLUE",
        "lavender":"LAVENDER","sapphire":"SAPPHIRE","sky":"SKY","teal":"TEAL","green":"GREEN",
        "yellow":"YELLOW","peach":"PEACH","red":"RED","maroon":"MAROON","pink":"PINK",
        "flamingo":"FLAMINGO","rosewater":"ROSEWATER","mauve":"MAUVE"}

def main():
    if len(sys.argv) != 3: sys.exit(__doc__)
    name, slug = sys.argv[1], sys.argv[2]
    c, P, bg, fg = palette(name)
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    hdr = ("# Generated by sh/gen-theme.py from the Ghostty theme %r.\n"
           "# Do not hand-edit: re-run the generator instead.\n#\n" % name)

    # 1. p10k palette
    with open(os.path.join(root, "zsh", "p10k-palette-%s.zsh" % slug), "w") as f:
        f.write(hdr + "# Sourced by zsh/p10k.zsh before the prompt style.\n\n")
        for k in ORDER:
            f.write('typeset -g P10K_COLOR_%s="%s"\n' % (k, c[k]))

    # 2. tmux @thm_* (catppuccin/tmux sets these; this overrides them)
    with open(os.path.join(root, "tmux", "theme-%s.conf" % slug), "w") as f:
        f.write(hdr + "# Sourced by tmux/tmux.conf after tpm, so these win.\n\n")
        for tk, ck in TMUX.items():
            f.write('set -g @thm_%s "%s"\n' % (tk, c[ck]))

    # 3. zsh-syntax-highlighting
    with open(os.path.join(root, "zsh", "syntax-%s.zsh" % slug), "w") as f:
        f.write(hdr + "\nZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)\ntypeset -gA ZSH_HIGHLIGHT_STYLES\n\n")
        S = {"comment":c["OVERLAY0"],"alias":c["GREEN"],"suffix-alias":c["GREEN"],
             "global-alias":c["GREEN"],"function":c["GREEN"],"command":c["GREEN"],
             "precommand":c["GREEN"]+",italic","autodirectory":c["PEACH"]+",italic",
             "single-hyphen-option":c["PEACH"],"double-hyphen-option":c["PEACH"],
             "back-quoted-argument":c["MAUVE"],"builtin":c["GREEN"],"reserved-word":c["MAUVE"],
             "hashed-command":c["GREEN"],"commandseparator":c["TEAL"],
             "command-substitution-delimiter":c["SUBTEXT0"],"path":c["TEXT"],
             "globbing":c["TEXT"],"single-quoted-argument":c["YELLOW"],
             "double-quoted-argument":c["YELLOW"],"dollar-quoted-argument":c["YELLOW"],
             "redirection":c["TEXT"],"unknown-token":c["MAROON"],
             "named-fd":c["TEXT"],"numeric-fd":c["TEXT"],"arg0":c["GREEN"],"default":c["TEXT"]}
        for k, v in S.items():
            f.write("ZSH_HIGHLIGHT_STYLES[%s]='fg=%s'\n" % (k, v))
        f.write('\n# autosuggestions, matching overlay0\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=%s"\n'
                % c["OVERLAY0"])

    # 4. k9s skin, same shape as the Catppuccin skins
    with open(os.path.join(root, "k9s", "skins", "%s.yaml" % slug), "w") as f:
        f.write(hdr.replace("# ", "# ") + "\nk9s:\n")
        f.write("  body:\n    fgColor: '%s'\n    bgColor: '%s'\n    logoColor: '%s'\n"
                % (c["TEXT"], c["BASE"], c["MAUVE"]))
        f.write("  prompt:\n    fgColor: '%s'\n    bgColor: '%s'\n    suggestColor: '%s'\n"
                % (c["TEXT"], c["MANTLE"], c["BLUE"]))
        f.write("  help:\n    fgColor: '%s'\n    bgColor: '%s'\n    sectionColor: '%s'\n"
                "    keyColor: '%s'\n    numKeyColor: '%s'\n"
                % (c["TEXT"], c["BASE"], c["GREEN"], c["BLUE"], c["MAROON"]))
        f.write("  frame:\n    title:\n      fgColor: '%s'\n      bgColor: '%s'\n"
                "      highlightColor: '%s'\n      counterColor: '%s'\n      filterColor: '%s'\n"
                % (c["TEAL"], c["BASE"], c["PINK"], c["YELLOW"], c["GREEN"]))
        f.write("    border:\n      fgColor: '%s'\n      focusColor: '%s'\n"
                % (c["MAUVE"], c["LAVENDER"]))
        f.write("    menu:\n      fgColor: '%s'\n      keyColor: '%s'\n      numKeyColor: '%s'\n"
                % (c["TEXT"], c["PINK"], c["PINK"]))
        f.write("    crumbs:\n      fgColor: '%s'\n      bgColor: '%s'\n      activeColor: '%s'\n"
                % (c["CRUST"], c["SURFACE1"], c["PEACH"]))
        f.write("    status:\n      newColor: '%s'\n      modifyColor: '%s'\n      addColor: '%s'\n"
                "      errorColor: '%s'\n      highlightColor: '%s'\n      killColor: '%s'\n"
                "      completedColor: '%s'\n"
                % (c["TEAL"], c["BLUE"], c["GREEN"], c["RED"], c["PEACH"], c["MAROON"], c["OVERLAY0"]))
        f.write("  info:\n    fgColor: '%s'\n    sectionColor: '%s'\n" % (c["PEACH"], c["TEXT"]))
        f.write("  views:\n    charts:\n      bgColor: '%s'\n      defaultDialColors: ['%s','%s']\n"
                "      defaultChartColors: ['%s','%s']\n"
                % (c["BASE"], c["BLUE"], c["RED"], c["BLUE"], c["RED"]))
        f.write("    table:\n      fgColor: '%s'\n      bgColor: '%s'\n      cursorFgColor: '%s'\n"
                "      cursorBgColor: '%s'\n      header:\n        fgColor: '%s'\n"
                "        bgColor: '%s'\n        sorterColor: '%s'\n"
                % (c["TEXT"], c["BASE"], c["CRUST"], c["SURFACE1"], c["TEXT"], c["BASE"], c["TEAL"]))
        f.write("    xray:\n      fgColor: '%s'\n      bgColor: '%s'\n      cursorColor: '%s'\n"
                "      graphicColor: '%s'\n"
                % (c["TEXT"], c["BASE"], c["SURFACE1"], c["BLUE"]))
        f.write("    yaml:\n      keyColor: '%s'\n      colonColor: '%s'\n      valueColor: '%s'\n"
                % (c["BLUE"], c["OVERLAY0"], c["TEXT"]))
        f.write("    logs:\n      fgColor: '%s'\n      bgColor: '%s'\n" % (c["TEXT"], c["BASE"]))

    # 5. Neovim palette, keyed like catppuccin.palettes.get_palette() so one
    #    consumer (nvim/lua/config/theme.lua) serves every profile.
    with open(os.path.join(root, "nvim", "lua", "themes", "%s.lua" % slug), "w") as f:
        f.write(hdr.replace("#", "--") + "-- Read by nvim/lua/config/theme.lua.\n\nreturn {\n")
        for k in ORDER:
            f.write('  %s = "%s",\n' % (k.lower(), c[k]))
        f.write("}\n")

    # 6. lazygit
    with open(os.path.join(root, "lazygit", "theme-%s.yml" % slug), "w") as f:
        f.write(hdr + "# Layered over lazygit/config.yml via $LG_CONFIG_FILE.\n\n")
        f.write("gui:\n  theme:\n")
        for k, v in [("activeBorderColor", c["BLUE"]), ("inactiveBorderColor", c["SUBTEXT0"]),
                     ("searchingActiveBorderColor", c["YELLOW"]), ("optionsTextColor", c["BLUE"]),
                     ("selectedLineBgColor", c["SURFACE0"]),
                     ("inactiveViewSelectedLineBgColor", c["OVERLAY0"]),
                     ("cherryPickedCommitFgColor", c["BLUE"]), ("cherryPickedCommitBgColor", c["SURFACE1"]),
                     ("markedBaseCommitFgColor", c["BLUE"]), ("markedBaseCommitBgColor", c["YELLOW"]),
                     ("unstagedChangesColor", c["RED"]), ("defaultFgColor", c["TEXT"])]:
            bold = "\n      - bold" if k == "activeBorderColor" else ""
            f.write("    %s:\n      - '%s'%s\n" % (k, v, bold))
        f.write("\n  authorColors:\n    '*': '%s'\n" % c["LAVENDER"])

    print("generated for %-24s -> p10k-palette-%s.zsh, theme-%s.conf, syntax-%s.zsh, %s.yaml, %s.lua, theme-%s.yml"
          % (name, slug, slug, slug, slug, slug, slug))

main()
