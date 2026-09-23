#!/usr/bin/env bash
# Remove iTerm2 from this machine (macOS only). Not part of `make install`:
# it removes an app the setup never installed, so you run it on purpose.
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

# --- the app and its settings ----------------------------------------------
# The app can already be gone while a dead Dock tile remains, so this half and
# the Dock half below are independent: never stop early because one is done.
if ((found == 0)); then
  skip "iTerm2 is not installed"
else
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
fi

# --- the Dock tile ----------------------------------------------------------
# The Dock keeps its own copy of the app's location, so a removed app leaves a
# "?" tile behind. persistent-apps is an array of dicts, which `defaults` can't
# edit in place: export it, edit with PlistBuddy, import it back so cfprefsd
# picks the change up instead of overwriting it.
if ((DRY_RUN)); then
  work="$(mktemp -t dev-setup-dock)"
else
  work="$BACKUP_DIR/removed/com.apple.dock.before.plist"
  mkdir -p "$(dirname "$work")"
fi
if defaults export com.apple.dock "$work" 2>/dev/null; then
  removed=0
  # Deleting shifts every later index down, so rescan from the start each time.
  while :; do
    idx=""
    i=0
    while url="$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:$i:tile-data:file-data:_CFURLString" "$work" 2>/dev/null)"; do
      case "$url" in *iTerm.app*) idx="$i"; break ;; esac
      i=$((i + 1))
    done
    [[ -n "$idx" ]] || break
    /usr/libexec/PlistBuddy -c "Delete :persistent-apps:$idx" "$work" >/dev/null
    removed=$((removed + 1))
  done
  if ((removed > 0)); then
    run defaults import com.apple.dock "$work"
    run killall Dock
    ok "removed $removed iTerm2 tile(s) from the Dock"
  else
    skip "iTerm2 is not in the Dock"
  fi
  ((DRY_RUN)) && rm -f "$work"
else
  warn "could not read the Dock settings; check it by hand"
fi
