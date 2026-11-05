# CORNEA.md

The `cornea` profile and the rules it is built to: a screen for keratoconus after
cross-linking (CXL), used both with scleral lenses in and with them out. Read this
before changing `theme-overrides/cornea-*.conf` or `ghostty/themes/Cornea *`, and
run `sh/check-cornea.py` after.

This is display ergonomics from the published research, not medical advice.
Items marked **ask your specialist** belong with the corneal or lens specialist.

## How to use it

```bash
make light-cornea    # the default: lenses in or out, any time the room is lit
make dark-cornea     # lenses in, room lit, and only if light mode feels too bright
```

| Situation | Mode | Also |
| --- | --- | --- |
| Lenses in, normal day | **light** | Screen brightness matched to the room (below) |
| Lenses out | **light**, always | Font up 3–5 steps (`Cmd +` / `Ctrl +`), room lights on |
| Lens fogging mid-day | light; dark briefly if it helps | Remove, rinse and refill the lens rather than adjusting the screen to it |
| Dark room | **neither** | Turn a light on. Dark text on light is fine; light text on dark in a dark room was the worst condition measured |

## Why light mode is the default

Your symptom, bright text blooming on a dark background, comes from
**aberrations** (coma, the dominant error in keratoconus). It does not come from
haze or scatter. Aberrations grow steeply with pupil size: coma scales roughly
with the cube of the pupil radius. A bright page makes the pupil smaller, so it
shrinks the blur itself.

- Dark text on light reads better in proofreading. This held regardless of room
  lighting and in older eyes that scatter more. The advantage **grows as text
  gets smaller**, and comes with **smaller pupils**.
  - Buchner & Baumgartner 2007, *Ergonomics* 50:1036
  - Piepenbrock et al. 2013, *Ergonomics* 56:1116
  - Piepenbrock et al. 2014, *Hum Factors* 56:942
  - Piepenbrock et al. 2014, *Ergonomics* 57:1670
- Light text on dark **in a dark room** was the worst condition tested.
  Dobres et al. 2017, *Appl Ergon*.
- **The counter-case:** for eyes whose problem is cloudy media, white-on-black
  can read faster (Legge et al. 1985). Haze peaks about 3 months after CXL and
  straylight can stay raised at 12 months (Pircher 2015, *JCRS*). If the
  treatment was recent, dark mode may genuinely feel better for a while.
  **Ask your specialist** whether your haze has settled.
- Scleral lenses remove most of the aberrations (meta-analysis of 19 studies,
  Pakbin 2026). With lenses in, polarity matters less. Without them it matters
  most, which is why light is the lenses-out mode.

## The colour rules

Contrast is measured with **APCA Lc**, the model behind WCAG 3. It replaces
WCAG 2's ratios, which overrate dark-mode contrast. Positive Lc is dark text on
light; negative is light on dark. `sh/check-cornea.py` enforces every row.

| Rule | Light | Dark | Why |
| --- | --- | --- | --- |
| Page | L\* 90–96 (`#efede8`, warm paper) | L\* 8–15 (`#1f1d1b`, never black) | Below L\* 90 no text colour can reach Lc 90. Pure black maximises halo. |
| Body text | Lc 85–95 (`#242320`, Lc 92) | Lc 70–80 (`#d3cfcc`, Lc −76) | Low contrast collapses the "visual span", worst under blur (Legge 1997). The dark cap limits bloom. |
| Comments | Lc ≥ 75 (Lc 76) | Lc ≥ 50 (Lc −58) | Comments are read, not decoration. Kanagawa Dragon's comments are Lc −22, under the Lc 30 floor for any text. |
| Faintest text (line numbers, hints) | Lc ≥ 60 (Lc 63) | Lc ≥ 40 (Lc −43) | APCA's Lc 30 floor, with margin |
| Syntax colours | Lc ≥ 75 on the page, ≥ 60 on bubbles and selection (Lc 80 / 63) | Lc ≥ 60 on the page, ≥ 55 on bubbles (Lc −65 / −61) | A colour must still be readable text; hue alone carries no legibility (Buchner 2007) |
| Saturation | OKLCH chroma ≤ 0.12 | ≤ 0.10 | Saturated colours focus at different depths (the eye has about 2 D of chromatic aberration); blue on dark is hardest to read (Ramasubramanian 2026) |
| Number of hues | **6**: red, amber, green, cyan, blue, violet | same | Fewer, well-separated hues. Catppuccin's other names reuse the nearest family. |
| Emphasis | Contrast and weight, **no italics** | same | A slant is one more stroke to smear. Weight up to Medium; very heavy strokes cost about 23% reading speed (Bernard 2013). |

Blue in the dark theme is deliberately light and desaturated (`#9ac0ec`).
Saturated blue on dark gave the most accommodative lag of any colour tested.

## The screen, beyond colours

| Setting | Lenses in | Lenses out | Evidence |
| --- | --- | --- | --- |
| Font size, macOS at ~60 cm | 15–16 pt (`font-size` is 14 today) | 18–22 pt | Size beats typeface for legibility (Legge 2026, Mansfield 1996). Monospace is as good as or better than proportional. |
| Weight | Regular / Medium | Medium | Bernard 2013 |
| Line height | `adjust-cell-height` 15–25% (2 px today) | same | Plausible; no code-specific study |
| Screen brightness | Match a sheet of paper beside it: ~80–150 nits in an office, 40–80 in a dim room | same | Physics: 400 lux makes white paper about 100 cd/m² |
| Dimming | macOS **Reduce white point** (60–80%) before greying the page | same | Keeps the page above L\* 90 |
| Room | Lit; a light behind the screen (bias light) is good, a window behind or beside it is not | same | Keratoconic eyes feel more discomfort glare (Plaka 2025) |
| Monitor | Top edge at or below eye level, 15–25° down-gaze, 50–70 cm | same | Down-gaze narrows the eye opening and slows tear evaporation |
| Blue-light filters / Night Shift | Comfort only | same | No effect on eye strain (Cochrane 2023, 17 randomised trials) |
| Breaks | 20-20-20: every 20 min, 20 s at 20 ft; blink fully | **critical** | Screen work lowers blink rate; matters for the lens's tear reservoir |

### Dell UltraSharp

The on-screen menu (joystick or buttons under the screen) is the same across
UltraSharp models. Set the monitor itself, not only macOS:

| Menu setting | Set to | Why |
| --- | --- | --- |
| Preset Mode | **Standard** | Vivid, Movie and Game push colour and contrast past what text needs |
| Brightness | **25–35%** in a normal room, **10–20%** in a dim one | White should look like paper beside it, not a lamp |
| Contrast | Default (about 75) | Higher mostly adds glare |
| Sharpness | Default (50), **never higher** | Sharpening draws bright edges around letters, which adds to the bloom |
| Dynamic Contrast / Smart HDR / HDR | **Off** | They change brightness on their own |
| ComfortView / ComfortView Plus | Either | Warmer colour only; no effect on eye strain |
| Response Time | **Normal** | "Fast" leaves faint ghost edges on scrolling text |

UltraSharps are flicker-free when dimmed, so low brightness costs nothing.

On the Mac: **System Settings → Displays → the Dell**, pick a size toward
"Larger Text" (on a 27" 4K, "looks like 2560×1440"; larger on lenses-out
days), and set the MacBook's own screen about as bright as the Dell so the eye
is not re-adapting between them. Top edge at or just below eye level, an arm's
length away, no window behind it or reflected in it.

Fonts with low-vision design intent exist with Nerd Font builds, if JetBrains
Mono ever feels wrong. There is no peer-reviewed study of either:

- Atkinson Hyperlegible Mono: cask `font-atkynson-mono-nerd-font`
- Intel One Mono: cask `font-intone-mono-nerd-font`

Lens fogging during the day is debris building up in the tear reservoir. It is
predicted by rapid tear exchange, not by reservoir depth (Fogt 2026). **Ask your
fitter** about fenestrated lenses or a different filling solution if it happens
often.

## Where it lives

| File | What |
| --- | --- |
| `ghostty/themes/Cornea {Light,Dark}` | The 16 ANSI slots plus `minimum-contrast = 3`, a floor for colours a program picks itself. `sh/theme.sh` names them by absolute path, so no link is needed. |
| `theme-overrides/cornea-{light,dark}.conf` | All 26 names, pinned, each annotated with its Lc. **Change colours here**, then re-run `sh/gen-theme.py "Cornea Light" cornea-light` (and Dark) and `sh/check-cornea.py`. |
| `nvim/lua/config/theme.lua` | Wears catppuccin.nvim with this palette poured in (`ON_CATPPUCCIN`), then removes italics and lifts line numbers from `surface1` (Lc ~14) to `overlay0`. |
| `sh/check-cornea.py` | The rules above, as a test |

## Sources

- Buchner & Baumgartner 2007, *Ergonomics* 50:1036. doi:10.1080/00140130701306413
- Piepenbrock, Mayr, Mund & Buchner 2013, *Ergonomics* 56:1116. doi:10.1080/00140139.2013.790485
- Piepenbrock, Mayr & Buchner 2014, *Hum Factors* 56:942. doi:10.1177/0018720813515509
- Piepenbrock, Mayr & Buchner 2014, *Ergonomics* 57:1670. doi:10.1080/00140139.2014.948496
- Dobres, Chahine & Reimer 2017, *Appl Ergon*. doi:10.1016/j.apergo.2016.11.001
- Legge, Rubin, Pelli & Schleske 1985, *Vision Res*; Legge et al. 1997, *Vision Res* (PMID 9274784)
- Villanueva 2023, *Ophthalmic Physiol Opt*. doi:10.1111/opo.13126 (straylight in keratoconus)
- Plaka 2025, *Cureus* (PMID 40225523) (discomfort glare in keratoconus)
- Pircher 2015, *J Cataract Refract Surg* (PMID 25953473) (haze and straylight after CXL)
- Pakbin 2026, *Int J Ophthalmol* (PMID 42959447) (scleral lenses and aberrations)
- Mansfield, Legge & Bane 1996, *IOVS* (PMID 8675391); Legge et al. 2026, *PLoS One* (PMID 41875185)
- Bernard, Kumar, Junge & Chung 2013, *Vision Res* (PMID 23523572) (stroke weight)
- Ramasubramanian 2026 (PMID 41797875) (text colour on dark, accommodation)
- Fogt 2021, *Clin Optom*; Fogt 2026, *Eye Contact Lens* (PMIDs 41984631, 41984605) (lens fogging)
- Cochrane review CD013244, 2023 (blue-light filtering)
- APCA: https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html

No study has tested screen polarity in keratoconus itself, or straylight with a
scleral lens in. The light-mode default is inferred from the optics and from the
studies above.
