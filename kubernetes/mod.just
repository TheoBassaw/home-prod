set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `bw get item sops-age-talos | yq -e '.fields[] | select(.name == "private-key").value'`
export KUBECONFIG := justfile_dir() + '/kubeconfig'

[private]
default: wait apply-secrets apply-cilium apply-flux

# Wait until api server is available
[private]
wait:
  until kubectl wait node --all --for=condition=Ready=False --timeout=10s 2>/dev/null \
    || kubectl wait node --all --for=condition=Ready=True --timeout=10s 2>/dev/null; do \
      echo "API server not yet reachable, retrying in 5 seconds..."; \
      sleep 5; \
  done

# Apply crds
apply-crds:
  flux-local build hr --path apps --no-hooks --no-skip-crds -A | yq ea -e 'select(.kind == "CustomResourceDefinition")' \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply global secrets
apply-secrets:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/global-secrets/namespace.yaml

  kubectl create secret generic cloudflare-api-token-secret -n global-secrets --dry-run=client -o yaml \
    --from-literal=api-token=`bw get item cloudflare-token-kubernetes | yq -e '.login.password'` \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  kubectl create secret generic smb-credentials -n global-secrets --dry-run=client -o yaml \
    --from-literal=username=`bw get item truenas-k8s-smb-creds | yq -e '.login.username'` \
    --from-literal=password=`bw get item truenas-k8s-smb-creds | yq -e '.login.password'` \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply cilium manifests
apply-cilium:
  flux-local build hr cilium -n kube-system --path apps --no-skip-secrets \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply flux and start reconciliation
apply-flux:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/flux-system/namespace.yaml

  flux-local build hr flux-operator -n flux-system --path apps --no-skip-secrets \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/flux-system/flux-operator/flux-instance.yaml
