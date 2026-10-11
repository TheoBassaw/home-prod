# home-prod

Bare-metal, GitOps-managed Home Production. Talos Linux nodes are provisioned
declaratively and everything above the OS is reconciled by Flux.

## Clusters

- **compute-cluster** — the Kubernetes cluster (workload, and infrastructure apps).
- **storage-cluster** — dedicated 3-node bulk storage (SeaweedFS). *Planned;
  see the design doc.*

## Tooling

GitHub Actions, Kubernetes, Flux, and Terraform.

## Repository layout

```text
.
├── .mise.toml              # tool versions, env, shell aliases
├── .justfile               # root task entrypoint
├── .github/workflows/      # CI: build + sign OCI artifact
├── compute-cluster/
│   ├── talos/              # Talos machine configs (topf)
│   └── kubernetes/
│       ├── apps/           # workloads, one directory per app
│       ├── ks/             # Flux entrypoints, one per namespace
│       ├── secrets/        # envsubst Secret templates
│       └── components/     # reusable kustomize components
├── storage-cluster/
│   ├── talos/              # Talos machine configs
│   └── kubernetes/         # (planned)
└── docs/                   # design documents
```

## Secrets

Secrets never live in git. `fnox` injects values from `pass` at apply time;
Kubernetes Secret manifests are `${VAR}` templates rendered with `envsubst`.
Required `pass` entries are declared in the per-scope `fnox.toml` files
(`compute-cluster/talos/`, `compute-cluster/kubernetes/`).

## Bootstrap

```sh
mise install
just bootstrap        # == just compute-cluster
```

The bootstrap waits for the K8S API → CRDs → namespaces → secrets →
Cilium → Flux → reconciliation. After that, Flux manages the cluster.

Individual phases:

```sh
just compute-cluster talos        # apply Talos configs, kubeconfig, talosconfig
just compute-cluster kubernetes   # CRDs → namespaces → secrets → CNI → Flux
```

## GitOps / CI

On every push to `main`, CI pushes the repo as a signed OCI artifact
(`flux push artifact` + `cosign sign`, tagged `latest`). The cluster's
`FluxInstance` pulls `oci://ghcr.io/theobassaw/home-prod:latest` and reconciles
each namespace.

## Documentation

- [Compute cluster design](docs/design.md)
- [Storage cluster design](docs/storage-cluster-design.md)

## Acknowledgements

Inspired by:

- https://github.com/khuedoan/homelab
- https://github.com/BeryJu/infrastructure
- https://github.com/onedr0p/home-ops
