set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `bw get item sops-age-talos | yq -e '.fields[] | select(.name == "private-key").value'`

[private]
default: apply-crds

# Apply crds
apply-crds:
  flux-local build hr --path apps --no-hooks --no-skip-crds -A | yq ea -e 'select(.kind == "CustomResourceDefinition")' \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f - --kubeconfig={{ justfile_dir() }}/kubeconfig
