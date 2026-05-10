set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export KUBECONFIG := justfile_dir() + '/kubeconfig'

[private]
default: wait apply-crds apply-namespaces apply-cilium apply-flux reconciliation

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

# Apply namespaces
apply-namespaces:
  find ./cluster -name "namespace.yaml" | while read -r f; do \
    kubectl apply --server-side --field-manager kubectl --force-conflicts -f "$f"; \
  done

# Apply secrets
apply-secrets:
  kubectl create secret generic doppler-token-auth-api -n security-system --dry-run=client -o yaml \
    --from-literal=dopplerToken=`doppler secrets get DOPPLER_TOKEN --plain` \
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
