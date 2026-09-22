#!/usr/bin/env bash
# MesloLGS NF, Powerlevel10k's recommended font.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "MesloLGS NF (Powerlevel10k's recommended font)"
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
added=0
for style in "Regular" "Bold" "Italic" "Bold Italic"; do
  file="MesloLGS NF ${style}.ttf"
  if [[ -f "$FONT_DIR/$file" ]]; then skip "$file"; continue; fi
  run mkdir -p "$FONT_DIR"
  run curl -fsSL -o "$FONT_DIR/$file" "$base/${file// /%20}"
  ok "$file"
  added=1
done
# Linux only picks up new fonts after the cache is rebuilt.
if is_linux && ((added)); then run fc-cache -f "$FONT_DIR"; fi
