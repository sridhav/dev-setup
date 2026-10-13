# k9s: Catppuccin, Latte or Mocha following the current light/dark mode.
#
# K9S_SKIN picks the skin without k9s's own config file being involved, so the
# repo only has to track skins/, which k9s never writes.
#
# The wrapper re-reads the flavour at launch rather than trusting the value this
# shell started with, so `make light` reaches a k9s opened from a shell that was
# already running. The export stays for anything that starts k9s without going
# through the function (a subprocess, a script).
#
# The rest of k9s's config dir stays machine-only: k9s rewrites config.yaml
# itself (a symlinked tracked file would leave every machine's tree dirty, and
# `make update` refuses to run on a dirty tree), and clusters/ holds a
# directory per cluster named after its full ARN.
#
# Kubeconfig is untouched on purpose: k9s reads $KUBECONFIG or ~/.kube/config.
export K9S_SKIN="catppuccin-${DEV_SETUP_FLAVOUR:-mocha}"

k9s() {
  if (( $+functions[dev_setup_flavour_now] )); then
    K9S_SKIN="catppuccin-$(dev_setup_flavour_now)" command k9s "$@"
  else
    command k9s "$@"
  fi
}
