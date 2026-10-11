# home-prod — Design Document

## Overview
Git-driven, GitOps-managed bare-metal Kubernetes homelab. Talos Linux hosts are
provisioned declaratively; everything above the OS is reconciled by Flux from a
signed OCI artifact. Secrets never live in git — they are pulled from `pass` at
apply time.

This document currently covers the compute cluster. A dedicated storage cluster
is planned as a follow-up.

## Repo layout
```
.                          root just/mise/fnox glue
└── compute-cluster/       the Kubernetes cluster
    ├── talos/             Talos machine configs (topf)
    └── kubernetes/        apps, ks (Flux entrypoints), secrets
```
Root `.justfile` delegates to `compute-cluster/mod.just`, which fans out to
`kubernetes/` and `talos/`.

## Toolchain (`.mise.toml`)
- **talosctl / kubernetes**: `1.14.0` / `1.36.1`
- **topf**: declarative Talos config generator + bootstrap
- **just**: task runner (`just bootstrap` = full install)
- **fnox**: secret injection backed by `pass` (+ `age` sync)
- **flate**: renders HelmReleases from OCIRepositories
- **kubectl, yq, vals, uv, sofka**

## Provisioning — Talos (`compute-cluster/talos/`)
- `topf.yaml`: 3 control-plane nodes (`talos-control-1..3`), cluster `home-k8s`,
  endpoint `k8s-api.home.paradisenetworkz.com:6443`, SecureBoot enabled.
- `schematic.yaml`: system extensions `drbd`, `i915`, `xe`, `intel-ucode`;
  kernel arg `lockdown=integrity`.
- `secrets.yaml`: cluster CA / etcd / k8s certs and bootstrap tokens, all
  `ref+envsubst://$VAR`, sourced via `fnox.toml` (backed by `pass`).
- `all/01-installation.yaml` (shared across nodes):
  - kube-proxy and flannel disabled (Cilium provides both)
  - encrypted `STATE` / `EPHEMERAL` volumes (LUKS2 + TPM)
  - PodSecurity defaults `enforce: baseline` / `warn: restricted`, with
    `piraeus-system` exempt
  - watchdog timer, weekly filesystem trim/scrub
  - networking backbone:
    - a `veth-workload` ↔ `veth-router` pair (`fda1:b2c3:d4e5:1::/127`)
    - `VRFConfig vrf-workload` (routing table 88)
  - Kubelet node label `zone: home`
- `control-plane/01-controlplane.yaml`:
  - Layer2 VIP `fd00:10:20:0::200` on `eth0`
  - removes the control-plane taint (all nodes schedulable)
  - Talos API access restricted to role `os:admin`, namespace `security-system`
- `node/<host>/01-patch.yaml` (per node):
  - explicit install disk by WWID, MAC-pinned `eth0`, static hostname
  - LVM `vg-pool` over a 1TB LUKS-encrypted `piraeus-data-1` volume
  - **host BGP** (two instances):
    - ASN `4200000002` (workload VRF) peering cluster ASN `4200000003`
    - ASN `4200000005` (fabric) peering upstream ASN `4200000000` with BFD,
      importing pod CIDRs `fd00:10:30::/56`, `10.30.0.0/16` and LB block
      `fd00:10:22::/64`

Dual-stack throughout: pods `fd00:10:30::/56` + `10.30.0.0/16`, services
`fd00:10:96::/108` + `10.96.0.0/12`, nodes `fd00:10:20::/64` + `10.20.0.0/24`.

## GitOps — Flux (`compute-cluster/kubernetes/`)
Directory roles:
- `apps/` — workloads, one directory per app
- `ks/` — one Flux `Kustomization` per namespace, pointing at `apps/<ns>`
- `secrets/` — envsubst secret templates
- `components/` — reusable kustomize components (e.g. `postgres`)

Flux itself:
- `apps/flux-system/flux-operator/fluxinstance.yaml` installs Flux 2.x from
  `ghcr.io/fluxcd`, then syncs from `oci://ghcr.io/theobassaw/home-prod:latest`
  at `./compute-cluster/kubernetes/ks`, interval 1h.
- `.github/workflows/push-sign-artifact.yaml`: on push to `main`, runs
  `flux push artifact` (tagged by short SHA), signs with `cosign`, then tags
  `latest`.
- `ks/*` Kustomizations run at interval 1h / retry 1m / `wait: true`.
  `flux-system`, `kube-system`, `network-system`, `storage-system`, and
  `piraeus-system` are `prune: false` (bootstrap/critical);
  `observability-system` and `security-system` are `prune: true`.

App pattern: each app directory contains `kustomization.yaml` +
`ocirepository.yaml` (chart source, pinned tag) + `helmrelease.yaml`
(`chartRef`).

## Bootstrap flow (`compute-cluster/kubernetes/mod.just`)
`wait` (API up) → `crds` (`flate build hr --only-crds`) → `namespaces` →
`secrets` (`fnox exec -- envsubst | kubectl apply`) → `cni` (Cilium + BGP) →
`flux` (Flux Operator) → `reconciliation` (apply the FluxInstance). After this,
Flux owns everything.

## Platform components by namespace
- **kube-system**: Cilium (kube-proxy replacement, netkit datapath, BIG TCP,
  BGP control plane, DSR/maglev, Hubble), cert-manager-csi-driver, descheduler,
  intel-gpu-resource-driver, metrics-server, reloader, snapshot-controller,
  spegel.
- **network-system**: cert-manager (Let's Encrypt DNS-01 via Cloudflare,
  self-signed root CA + `root-ca-clusterissuer`), Envoy Gateway (DualStack,
  3 replicas, HTTPS on 443), k8s-gateway, trust-manager (root-ca bundle).
- **storage-system**: CloudNative-PG Postgres 18 (3 instances, TLS-only,
  hourly barman backups to TrueNAS S3), kopiur.
- **piraeus-system**: Piraeus / LINSTOR (DRBD protocol C + TLS, LVM `vg-pool`);
  StorageClasses `piraeus-local` (1 replica) and `piraeus-replicated`
  (2 replicas).
- **security-system**: External Secrets (+ password `ClusterGenerator`),
  Authentik (SSO, Postgres over TLS), Tuppr (Talos upgrades).
- **observability-system**: VictoriaMetrics k8s stack, Grafana Operator
  (HA, Postgres backend, anonymous auth, route `grafana.paradisenetworkz.com`).
- **flux-system**: Flux Operator + Tofu controller.

## Networking design
- Host BGP (Talos) advertises pod CIDRs and LB VIPs to the fabric router
  (ASN `4200000000`).
- Cilium BGP (node ASN `4200000003` ↔ host ASN `4200000002`) advertises
  LoadBalancer IPs from the `CiliumLoadBalancerIPPool` `fd00:10:22::/64`.
- L2 VIP fronts the control plane; workload traffic is isolated in a VRF.
- North-south traffic enters via Envoy Gateway; DNS via k8s-gateway; TLS issued
  by cert-manager.

## Secrets design
`fnox` + `pass` + `envsubst`. Per-scope `fnox.toml` files (`talos/`,
`kubernetes/`) define the `pass` prefix and secret refs; Kubernetes Secrets are
`${VAR}` templates rendered and applied during bootstrap. No plaintext secrets
are stored in git.

## CI/CD
Single workflow triggered on `main`: build a signed OCI artifact → Flux pulls
tag `latest` → reconciles each namespace Kustomization → HelmReleases resolved
via flate/OCIRepository.
