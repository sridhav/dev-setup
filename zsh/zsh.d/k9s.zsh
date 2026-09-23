# k9s: Catppuccin Mocha.
#
# K9S_SKIN picks the skin without k9s's own config file being involved, so the
# repo only has to track skins/, which k9s never writes.
#
# The rest of k9s's config dir stays machine-only: k9s rewrites config.yaml
# itself (a symlinked tracked file would leave every machine's tree dirty, and
# `make update` refuses to run on a dirty tree), and clusters/ holds a
# directory per cluster named after its full ARN.
#
# Kubeconfig is untouched on purpose: k9s reads $KUBECONFIG or ~/.kube/config.
export K9S_SKIN="catppuccin-mocha"
