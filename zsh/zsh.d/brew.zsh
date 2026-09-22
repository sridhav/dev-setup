# Homebrew: /opt/homebrew (Apple Silicon), /usr/local (Intel Mac),
# /home/linuxbrew/.linuxbrew (Linux).
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew $HOME/.linuxbrew/bin/brew; do
  [ -x "$_brew" ] && eval "$($_brew shellenv zsh)" && break
done
unset _brew
export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"
