set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export KUBECONFIG := justfile_dir() + '/kubeconfig'

[private]
default: wait apply-manifests start-reconciliation

# Wait until api server is available
[private]
wait:
  until kubectl wait node --all --for=condition=Ready=False --timeout=10s 2>/dev/null \
    || kubectl wait node --all --for=condition=Ready=True --timeout=10s 2>/dev/null; do \
      echo "API server not yet reachable, retrying in 5 seconds..."; \
      sleep 5; \
  done

# Apply manifests
apply-manifests:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/flux-system/namespace.yaml
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/security-system/namespace.yaml

  flate build hr --path cluster --only-crds \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  flate build hr cilium --path cluster --skip-secrets=false \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  flate build hr flux-operator --path cluster --skip-secrets=false -n flux-system \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  doppler run -- kubectl create secret generic doppler-token-auth-api \
    --from-literal=dopplerToken='${CLOUDFLARE_TOKEN}' --dry-run=client -n security-system -o yaml \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Start reconciliation
start-reconciliation:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f bootstrap/flux.yaml
