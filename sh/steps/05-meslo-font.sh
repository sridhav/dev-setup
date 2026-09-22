#!/usr/bin/env bash
# MesloLGS NF, Powerlevel10k's recommended font.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "MesloLGS NF (Powerlevel10k's recommended font)"
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
for style in "Regular" "Bold" "Italic" "Bold Italic"; do
  file="MesloLGS NF ${style}.ttf"
  if [[ -f "$HOME/Library/Fonts/$file" ]]; then skip "$file"; continue; fi
  run curl -fsSL -o "$HOME/Library/Fonts/$file" "$base/${file// /%20}"
  ok "$file"
done
