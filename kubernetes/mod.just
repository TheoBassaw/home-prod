set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default: wait crds namespaces secrets cni flux reconciliation

# Wait until api server is available
[private]
wait:
  until kubectl wait node --all --for=condition=Ready=False --timeout=10s 2>/dev/null \
    || kubectl wait node --all --for=condition=Ready=True --timeout=10s 2>/dev/null; do \
      echo "API server not yet reachable, retrying in 5 seconds..."; \
      sleep 5; \
  done

# Apply CRDS
crds:
  flate build hr --path apps --only-crds \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Apply Namespaces
namespaces:
  find ./apps -name "namespace.yaml" | while read -r f; do \
    kubectl apply --server-side --field-manager kubectl --force-conflicts -f "$f"; \
  done

# Apply Secrets
secrets:
  find ./secrets -type f | while read -r f; do \
    envsubst < "$f" | kubectl apply --server-side --field-manager kubectl --force-conflicts -f - ; \
  done

# Apply Cilium
cni:
  flate build hr cilium --path apps --skip-secrets=false \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

  until kubectl apply -f apps/kube-system/cilium/cilium-bgp.yaml; do sleep 1; done

# Apply Flux Operator
flux:
  flate build hr flux-operator --path apps --skip-secrets=false -n flux-system \
    | kubectl apply --server-side --field-manager kubectl --force-conflicts -f -

# Start reconciliation
reconciliation:
  kubectl apply --server-side --field-manager kubectl --force-conflicts -f apps/flux-system/flux-operator/fluxinstance.yaml
