#!/usr/bin/env bash
# Claude Code CLI.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Claude Code CLI"
# No Homebrew formula exists and the `claude-code` cask is macOS only, so both
# OSes use Anthropic's installer. It drops one self-updating binary in
# ~/.local/bin, which zsh/zsh.d/path.zsh already puts on PATH.
CLAUDE_BIN="$HOME/.local/bin/claude"
set_aside "$CLAUDE_BIN"
if command -v claude >/dev/null 2>&1; then
  skip "claude ($(command -v claude))"
  exit 0
fi
run sh -c 'curl -fsSL https://claude.ai/install.sh | bash'
ok "claude"
