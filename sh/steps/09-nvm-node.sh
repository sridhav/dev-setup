#!/usr/bin/env bash
# nvm and Node.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "nvm and Node $NODE_VERSION"
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  skip "nvm"
else
  # PROFILE=/dev/null: the zshrc already loads nvm, don't let the installer append to it.
  run env PROFILE=/dev/null bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh)"
  ok "nvm"
fi
((DRY_RUN)) && exit 0
set +u # nvm.sh is not nounset-clean
# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"
if nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
  skip "node $NODE_VERSION"
else
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  ok "node $NODE_VERSION"
fi
