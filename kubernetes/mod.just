set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export KUBECONFIG := justfile_dir() + '/kubeconfig'

[private]
default: wait apply-crds apply-namespaces apply-secrets apply-cilium apply-flux reconciliation

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
  flux-local build hr --path cluster --no-hooks --no-skip-crds -A | yq ea -e 'select(.kind == "CustomResourceDefinition")' \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

apply-namespaces:
  flux-local build ks --path cluster -A | yq ea -e 'select(.kind == "Namespace")' \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply global secrets
apply-secrets:
  kubectl create secret generic cloudflare-api-token-secret -n global-secrets --dry-run=client -o yaml \
    --from-literal=api-token=`bw get item cloudflare-token-kubernetes | yq -e '.login.password'` \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  kubectl create secret generic smb-credentials -n global-secrets --dry-run=client -o yaml \
    --from-literal=username=`bw get item truenas-k8s-smb-creds | yq -e '.login.username'` \
    --from-literal=password=`bw get item truenas-k8s-smb-creds | yq -e '.login.password'` \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply cilium manifests
apply-cilium:
  flux-local build hr cilium -n kube-system --path cluster --no-skip-secrets \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply flux operator manifests
apply-flux:
  flux-local build hr flux-operator -n flux-system --path cluster --no-skip-secrets \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Start reconciliation
reconciliation:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/flux-system/flux-operator/flux-instance.yaml
