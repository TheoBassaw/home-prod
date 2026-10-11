# Storage Cluster — Design Document

## 1. Purpose and scope

A dedicated 3-node Talos + Kubernetes storage cluster that provides, for the
rest of the homelab:

- **Bulk RWX file storage** for important documents, pictures, and videos.
  This data must live on local disks — the cluster must not depend on the
  internet being up to serve it.
- **An S3 target** for backups from the compute cluster (CloudNativePG/barman,
  and non-database PVCs via VolSync).

### Non-goals

- No databases or workloads needing good random read/write performance.
- Everything that is not important data is assumed to be re-downloadable from
  other sources; the cluster exists to make that less likely, not as the only
  copy.
- No public/internet exposure. LAN-only.

### Design principles

- **GitOps**: the signed OCI artifact is the source of truth; Flux reconciles
  the storage cluster the same way it reconciles the compute cluster.
- **Local-authoritative data** with an offsite copy (Backblaze B2). This is
  "Posture 1": local disks serve reads/writes, and a continuous data mirror
  pushes changes to B2. No reliance on cloud for normal operation.
- **Workload identity (OIDC)** for S3 consumers — no per-application static
  secrets.

## 2. Hardware and capacity

Per node (×3):

- 16 GB RAM
- 2 × 1 TB M.2 2280 consumer SSD (NVMe)
- 2 × 2.5GbE NICs (one uplink active until switching is improved)
- A UPS (assumed) — this is the primary mitigation for the lack of
  power-loss-protection (PLP) on consumer SSDs

Capacity:

- Raw: 3 nodes × 2 × 1 TB = **6 TB**
- Replication factor 2 (RF2): **~3 TB usable** before filesystem / volume /
  index overhead
- Note: compute-cluster backups (CNPG + VolSync) are also written here before
  being mirrored to B2, so plan the important-data set against this budget.

Notes on consumer SSDs: RF2 doubles writes, there is no PLP, and M.2 SSDs have
finite endurance. SeaweedFS's append-only volume format plus per-needle
checksums, together with RF2 and the offsite copy, cover this; the UPS removes
the unplanned-power-loss window.

## 3. Talos / OS layer

Mirrors the compute cluster's patterns (`topf`, SecureBoot, LUKS, watchdog,
trim/scrub).

- **Provisioning**: `topf.yaml` with 3 control-plane nodes, cluster name
  `home-storage`, its own endpoint, SecureBoot enabled.
- **Volumes**: two LUKS-encrypted node-local volumes per node, created with
  `RawVolumeConfig` and exposed at stable paths with `Mounts`. SeaweedFS volume
  servers consume these directly via `hostPath` (no PVCs).
- **Control-plane endpoint**: an **L2 VIP** (e.g. `fd00:10:40::200` on
  `eth0`), until an L3/anycast VIP is implemented.
- **Node labels**: each node gets a **distinct rack label** so SeaweedFS can
  place replicas on different nodes (replication `010`).
- **Encryption keys**: Talos secrets live in `pass` and are injected via
  `fnox`/`envsubst` at bootstrap.

### Proposed addressing

| Purpose  | IPv4             | IPv6              |
|----------|------------------|-------------------|
| Nodes    | `10.40.0.0/24`   | `fd00:10:40::/64` |
| Pods     | `10.50.0.0/16`   | `fd00:10:50::/56` |
| Services | `10.97.0.0/12`   | `fd00:10:97::/108`|
| LB pool  | —                | `fd00:10:24::/64` |

Dual-stack throughout, consistent with the compute cluster.

## 4. Networking (redundancy + BGP/ECMP)

Goal: aggregate/balance traffic with **BGP + ECMP** across the 3 nodes.

- **Phase 1 (current switching)**: one 2.5GbE uplink per node. Each node runs
  BGP peering the fabric router (proposed fabric ASN `4200000006` → router
  `4200000000`; Cilium ASN `4200000007`). The **storage service VIP** (S3 +
  filer) is advertised by all 3 nodes, so the router ECMPs across nodes.
- **Phase 2 (better switching)**: add the second NIC as a second routed L3
  link with its own BGP session. BGP multipath then yields ECMP across nodes
  *and* links. Config-only change.

Caveats:

- ECMP balances **many flows**; a single flow is still capped at 2.5GbE.
- With RF2, inter-node replication competes for the single uplink; ~295 MB/s
  is the practical ceiling until Phase 2.

## 5. Cluster shape and repo layout

- New `storage-cluster/kubernetes/{apps,ks,secrets,components}` mirroring the
  compute cluster.
- Its own `FluxInstance` syncing `./storage-cluster/kubernetes/ks` from the
  same signed OCI artifact (`oci://ghcr.io/theobassaw/home-prod`).
- Root `.justfile` gains `mod storage-cluster`; `storage-cluster/mod.just`
  gains `mod kubernetes` (it currently only has `talos`).
- Bootstrap chain mirrors compute:
  `wait → crds → namespaces → secrets → cni → flux → reconciliation`.
- CI is unchanged: the whole repo is already pushed/signed as one artifact.

## 6. SeaweedFS design

Topology (operator-managed `Seaweed` CR):

- **3× master** (Raft quorum; tolerates one node loss). Enable
  `master.persistence` so the master keeps its raft state / `TopologyId`
  across restarts. On a full DR rebuild a fresh identity is minted, which is
  acceptable because volume servers re-report their volumes and the master
  rebuilds the layout.
- **Volume servers as a `DaemonSet`** on `hostPath`, one per node, using the
  two encrypted node-local volumes (`/data0`, `/data1`). No PVCs.
- **2–3× filer**, serving the namespace, S3 gateway, and FUSE/CSI.
- **Standalone S3 gateway** with embedded IAM.

Data placement:

- `replication: "010"` with 3 rack labels → 2 copies on 2 different nodes.
- RF2 tolerates exactly one node failure with no data loss; recovery of an
  under-replicated volume is manual via `volume.fix.replication` (see §10).

Filer metadata store:

- **External CloudNative-PG Postgres** instead of LevelDB2. The operator points
  the filer at it via `filer.configSecret` (keeps credentials out of git).
  This makes the namespace, file→chunk map, and embedded S3 IAM state durable,
  transactional, and covered by CNPG/barman backups.
- CNPG shape: 3 instances, own TLS via cert-manager, anti-affinity across the
  3 nodes.
- Postgres PVs use a **local-path-provisioner** CSI on a small local volume;
  CNPG's synchronous replication provides the HA, so no need to replicate the
  PV itself. This keeps both 1 TB M.2s exclusively for SeaweedFS.

TLS:

- **Internal** master↔volume↔filer mTLS is handled by the operator through
  **cert-manager** (it auto-provisions a self-signed issuer chain by default;
  no hand-managed CA).
- **External** serving certs (S3 gateway, filer) use **Let's Encrypt** (DNS-01
  via Cloudflare) terminated by the storage cluster's own Gateway + internal
  DNS. Public trust means cross-cluster consumers need no custom CA.

Buckets and IAM:

- Declarative `Bucket` CRs.
- IAM policies/roles declared in git (`iam.json` / operator IAM CRDs); state is
  stored in the filer store (Postgres) and therefore backed up.

## 7. Cross-cluster consumption

- **RWX**: the compute cluster runs an external `SeaweedCSIDriver` with
  `filerAddress` pointing at the storage filer → RWX media/docs PVCs. This path
  is filer/TLS-based and does not use S3 IAM.
- **S3**: compute-cluster clients (CloudNativePG/barman, VolSync/rclone, apps)
  use the storage S3 VIP.
- **Secrets/endpoints** via `fnox` → bootstrap secrets / External Secrets.

### Authentication — OIDC workload identity (primary)

Use OIDC + STS `AssumeRoleWithWebIdentity` so consumers obtain temporary
credentials via their Kubernetes service-account tokens — **no per-app static
secrets**.

- SeaweedFS's advanced IAM (`-iam.config`, mounted ConfigMap) defines an OIDC
  provider, STS, `roleMapping` (claims → roles), `policies`, and `roles`.
  Onboarding a consumer = a policy/role-mapping rule in git.
- The **OIDC issuer is the compute cluster's API server**. Required one-time
  setup:
  - Compute API server `--service-account-issuer` set to a stable, reachable
    URL (Talos `apiServer.extraArgs`); ideally set at bootstrap.
  - The projected service-account token audience must equal the OIDC
    `clientId`.
  - Role mapping by claim, e.g. `sub` =
    `system:serviceaccount:<namespace>:<serviceaccount>`.
  - A single STS `signingKey` in `iam.json` (one secret, sourced from `pass` —
    not per-app).

**Recommended: expose the issuer through the compute cluster's Envoy Gateway.**
Route only `/.well-known/openid-configuration` and `/openid/v1/jwks` to
`default/kubernetes:443`:

- HTTPRoute on the `envoy` gateway (path-restricted — never route arbitrary API
  paths).
- `ReferenceGrant` in `default` allowing the route's namespace to reference the
  `kubernetes` Service.
- `BackendTLSPolicy` with the compute cluster's k8s CA so Envoy trusts the
  API server's serving cert (the CA stays on the compute side).
- TLS cert SAN covering the issuer hostname (wildcard `*.paradisenetworkz.com`
  or an explicit SAN).
- LAN DNS: the storage-side filer must resolve the issuer hostname to the
  compute Envoy VIP.

Result: SeaweedFS sees a publicly-trusted (LE) cert, so **no `tlsCaCert` is
required on storage**. Caveats: an extra hop/dependency (mitigated by JWKS
caching, `jwksCacheTTLSeconds`), a cluster-wide API server issuer change, and
strict path scoping on the route.

**Fallback: direct to the API server.** Point the OIDC issuer at a DNS name
resolved to the compute API server (L2 VIP), add that name to the API server
`certSANs`, and set the provider's `tlsCaCert` to the compute cluster's k8s CA
(already in `pass` as `TALOS_CERTS_K8S_CRT`, mounted into the filer). Fewer
moving parts, but the CA is shipped to storage.

**Escape hatch**: for any client that genuinely cannot do web identity, a
single shared static role (or a credential-injecting sidecar/proxy) — a
documented exception, never per-app `pass` entries.

## 8. Backup (Posture 1 — local-authoritative)

Data classes and their backup paths:

| Data | Lives on | Backup |
|---|---|---|
| RWX media/docs | SeaweedFS volumes (hostPath) | RF2 + continuous `filer.backup` data mirror → B2 |
| SeaweedFS filer metadata + IAM | CNPG Postgres | CNPG/barman → B2 |
| Compute CNPG databases | compute | barman → storage S3 → mirrored to B2 |
| Compute non-DB PVCs (SQLite/file DBs) | compute local (piraeus/local-path) | VolSync restic, `copyMethod: Snapshot` → storage S3 → B2 |

- The SeaweedFS **data mirror** (`weed filer.backup`, run by the operator as a
  Deployment) subscribes to filer changes and writes file contents to B2 in the
  source directory structure. Objects written through the S3 gateway live in
  the filer tree, so they are mirrored too.
- B2 bucket: **versioning enabled + 14-day lifecycle** for short-term
  ransomware/accidental-delete recovery.
- No native SeaweedFS metadata snapshots are used; metadata DR is CNPG/barman's
  job.

### What the CRs do and do not persist

Flux reapplies the CRs (`Seaweed`, `Bucket`, `S3Identity`, `S3Policy`,
`S3PolicyBinding`, `SeaweedCSIDriver`, CNPG `Cluster`); operators rebuild their
child resources. What is *not* captured by "Flux reapply":

- **Filer metadata / IAM**: in Postgres → CNPG backups (not etcd).
- **Volume data**: on hostPath → RF2 + B2 mirror.
- **S3 credentials**: with OIDC-first there are no generated per-app keys. If a
  static role is ever used, its key pair is pre-seeded from `pass` (adopted by
  `S3Credentials`) rather than operator-generated, so nothing is etcd-only.
- **Master raft state / `TopologyId`**: kept via `master.persistence`.

### Cluster state and secrets

- **Git is the source of truth** for desired state.
- **etcd is not backed up as primary DR.** Restoring etcd can fight GitOps
  (reintroducing pruned/stale resources). A periodic `talosctl etcd snapshot`
  may be kept as a last-resort safety net only.
- The only non-declarative secrets to externalize into `pass`:
  - the compute cluster's cert-manager **root CA** (see compute-cluster
    follow-up),
  - the SeaweedFS **STS signing key** (single),
  - **B2** credentials,
  - **Talos** secrets,
  - admin credentials.
- IAM (`/etc/iam/identity.json`) is stored in the filer → Postgres → backed up.

## 9. Restore and DR

Two scenarios:

**In-place recovery (volumes intact)** — filer metadata via CNPG/barman restore
and rollback. Metadata restore is valid only because the volume data still
exists.

**New-cluster DR (volumes gone)** — metadata restore alone is insufficient
(fids would dangle). The DR source of truth is the **logical B2 data mirror**:

1. Stand up a fresh cluster via GitOps.
2. Re-ingest the B2 mirror into the fresh filer (a GitOps-gated Job copying the
   mirror bucket back through the filer). The cluster regenerates chunks and
   metadata.
3. Consumers wait on the restore via Flux `dependsOn`.

Notes:

- Re-ingest RTO scales with the size of the important-data set (acceptable;
  small).
- SeaweedFS's documented "mirror a cluster" method (volume-level `weed backup`
  + `fs.meta.save`/`load`) is a possible faster, fid-preserving alternative, but
  requires pausing writes and is not turnkey; out of scope for now.
- Run a periodic restore drill.

## 10. Known gaps and roadmap

- **RF2 heals manually**: after a node loss there is no automatic
  re-replication; run `volume.fix.replication` (scheduled) to restore RF2. Until
  then affected volumes are effectively RF1. Master quorum (2/3) survives one
  node loss; a second loss risks both quorum and data.
- **No turnkey fid-preserving auto-restore**: new-cluster DR is a re-ingest, not
  a metadata replay.
- **Client web-identity support** must be verified per consumer (barman,
  rclone/VolSync); the static-role escape hatch covers stragglers.
- **Single uplink** is the inter-node replication bottleneck until Phase 2.
- **Capacity ceiling**: ~3 TB usable, shared with compute backups; plan the
  important-data set accordingly.
- **PLP**: residual risk limited to volume data; UPS + RF2 + B2 mitigate.
- **B2 window**: 14-day versioning/lifecycle.
- **Compute-side follow-up**: externalize the compute cluster's cert-manager
  root CA into `pass` (and, for the Gateway OIDC option, add
  `--service-account-issuer` / SAN / ReferenceGrant / BackendTLSPolicy).
