# nvm, loaded lazily: sourcing nvm.sh costs ~200 ms, most of shell startup.
#
# The default Node goes on PATH right away (so node, npm, and the language
# servers Neovim's Mason installs keep working everywhere); nvm itself loads
# the first time you run `nvm`.
export NVM_DIR="$HOME/.nvm"

() {
  [[ -s $NVM_DIR/nvm.sh ]] || return
  # alias/default holds e.g. "24" or "v24.16.0"; pick the newest installed match.
  local alias_ver=${$(<$NVM_DIR/alias/default 2>/dev/null)#v}
  local -a dirs=($NVM_DIR/versions/node/v${alias_ver}*(N/nOn))
  if [[ -n $alias_ver && -n $dirs[1] ]]; then
    path=($dirs[1]/bin $path)
  else
    # Alias we can't resolve cheaply (e.g. lts/*): fall back to loading nvm now.
    source $NVM_DIR/nvm.sh
    return
  fi

  nvm() {
    unfunction nvm
    source $NVM_DIR/nvm.sh
    [[ -s $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion
    nvm "$@"
  }
}
