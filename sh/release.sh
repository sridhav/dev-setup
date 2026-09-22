#!/usr/bin/env bash
# Tag the current commit as a named version (vYYYY.MM.DD, or pass one) and push it.
# Optional: every commit is already a version. Tags mark ones you trust.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
g() { git -C "$DOTFILES" "$@"; }

tag="${1:-v$(date +%Y.%m.%d)}"
if g rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  tag="$tag.$(date +%H%M)"
fi
[[ -z "$(g status --porcelain)" ]] || { warn "Uncommitted changes. Run 'make push' first."; exit 1; }
g tag -a "$tag" -m "dev-setup $tag"
g push --quiet origin "$tag"
ok "released $tag ($(g rev-parse --short HEAD))"
