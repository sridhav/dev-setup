#!/usr/bin/env bash
# Remove iTerm2 from this machine (macOS only). Not part of `make install`:
# it deletes an app the setup never installed, so you run it on purpose.
# Nothing is deleted outright -- everything moves into ~/.dev-setup-backup/.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

step "Remove iTerm2"

if ! is_macos; then
  skip "iTerm2 is macOS only"
  exit 0
fi

ITERM_PATHS=(
  "/Applications/iTerm.app"
  "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  "$HOME/Library/Application Support/iTerm2"
  "$HOME/Library/Saved Application State/com.googlecode.iterm2.savedState"
  "$HOME/Library/Caches/com.googlecode.iterm2"
)

found=0
for path in "${ITERM_PATHS[@]}"; do
  if [[ -e "$path" || -L "$path" ]]; then found=1; break; fi
done
if ((found == 0)); then
  skip "iTerm2 is not installed"
  exit 0
fi

# Quit it first, or the move leaves a running app with no bundle.
if pgrep -x iTerm2 >/dev/null 2>&1; then
  info "quitting iTerm2"
  run osascript -e 'tell application "iTerm" to quit' || warn "could not quit iTerm2; close it and re-run"
fi

# If Homebrew owns it, let Homebrew remove it so its receipt goes too.
if brew list --cask 2>/dev/null | grep -qx iterm2; then
  info "uninstalling the Homebrew cask"
  run brew uninstall --cask iterm2
fi

run mkdir -p "$BACKUP_DIR/removed"
run chmod 700 "$HOME/.dev-setup-backup" "$BACKUP_DIR"
for path in "${ITERM_PATHS[@]}"; do
  [[ -e "$path" || -L "$path" ]] || continue
  # Keep the full path under removed/ so it's obvious where it came from.
  dest="$BACKUP_DIR/removed/${path#/}"
  run mkdir -p "$(dirname "$dest")"
  # /Applications looks writable but macOS App Management (14+) still blocks
  # moving another app's bundle, so try as us first and escalate if it fails.
  if ! run mv "$path" "$dest" 2>/dev/null; then
    info "needs sudo (macOS App Management protects /Applications)"
    run as_root mv "$path" "$dest"
  fi
  ok "$path → $dest"
done

info "moved, not deleted: restore with mv if you want it back"
