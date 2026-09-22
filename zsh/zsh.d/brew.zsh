# Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$_brew" ] && eval "$($_brew shellenv zsh)" && break
done
unset _brew
export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"
