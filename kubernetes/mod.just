set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `bw get item sops-age-talos | yq -e '.fields[] | select(.name == "private-key").value'`

[private]
default: apply-crds apply-cilium

# Apply crds
apply-crds:
  flux-local build hr --path apps --no-hooks --no-skip-crds -A | yq ea -e 'select(.kind == "CustomResourceDefinition")' \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts --kubeconfig={{ justfile_dir() }}/kubeconfig -f -

apply-cilium:
  flux-local build hr cilium -n kube-system --path apps --no-skip-secrets \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts --kubeconfig={{ justfile_dir() }}/kubeconfig -f -
