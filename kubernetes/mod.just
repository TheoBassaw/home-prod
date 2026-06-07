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
  flate build hr --path cluster --only-crds \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  find ./cluster -name "namespace.yaml" | while read -r f; do \
    kubectl apply --server-side --field-manager kubectl --force-conflicts -f "$f"; \
  done

  find ./cluster -name "secret.yaml" | while read -r f; do \
    envsubst < "$f" | kubectl apply --server-side --field-manager kubectl --force-conflicts -f - ; \
  done

  flate build hr cilium --path cluster --skip-secrets=false \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  flate build hr flux-operator --path cluster --skip-secrets=false \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Start reconciliation
start-reconciliation:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f cluster/flux-system/flux-operator/flux-instance.yaml
