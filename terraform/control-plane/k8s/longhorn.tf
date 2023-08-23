resource "helm_release" "longhorn" {
  name             = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = "1.5.1"
  wait             = true
  create_namespace = true

  set {
    name  = "persistence.defaultDataLocality"
    value = "best-effort"
  }

  set {
    name  = "persistence.reclaimPolicy"
    value = "Retain"
  }
}