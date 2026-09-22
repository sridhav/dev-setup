#!/usr/bin/env bash
# Generate ~/.zsh.d/personal.zsh with machine-specific credentials.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
parse_flags "$@"

DEST="$HOME/.zsh.d/personal.zsh"

step "personal credentials (~/.zsh.d/personal.zsh)"

if [[ -f "$DEST" ]] && ! ((FORCE)); then
  skip "personal.zsh"
  exit 0
fi

# Interactive prompts — can't go through run() since they need a tty.
printf '  Enter GitHub username: '
read -r github_user
printf '  Enter GitHub personal access token: '
read -rs github_token
printf '\n'

if [[ -z "$github_user" || -z "$github_token" ]]; then
  warn "Skipping: both username and token are required."
  exit 1
fi

[[ -f "$DEST" ]] && set_aside "$DEST"
mkdir -p "$(dirname "$DEST")"

cat > "$DEST" <<EOF
export PERSONAL_GITHUB_USER="$github_user"
export PERSONAL_GITHUB_TOKEN="$github_token"
EOF
chmod 600 "$DEST"
ok "personal.zsh written"
