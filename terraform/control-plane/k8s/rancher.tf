data "kubectl_file_documents" "rancher_backup" {
  content = file("${path.module}/manifests/rancher-backup.yaml")
}

resource "random_password" "bootstrap" {
  count  = var.profile == "PRIMARY" ? 1 : 0
  length = 16
}

resource "helm_release" "rancher" {
  count            = var.profile == "PRIMARY" ? 1 : 0
  name             = "rancher"
  namespace        = "cattle-system"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  create_namespace = true
  wait             = true
  values           = [templatefile("${path.module}/templates/rancher-values.yaml", {
    bootstrapPassword = random_password.bootstrap[0].result,
    hostname          = "rancher-prod.paradisenetworkz.com"
  })]

  depends_on = [
    helm_release.external_dns_cf,
    helm_release.cert_manager,
    helm_release.ingress_nginx,
    helm_release.longhorn
  ]
}

resource "helm_release" "rancher_backup_crd" {
  count            = var.profile == "PRIMARY" ? 1 : 0
  name             = "rancher-backup-crd"
  namespace        = "cattle-resources-system"
  repository       = "https://charts.rancher.io"
  chart            = "rancher-backup-crd"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_backup" {
  count      = var.profile == "PRIMARY" ? 1 : 0
  name       = "rancher-backup"
  namespace  = "cattle-resources-system"
  repository = "https://charts.rancher.io"
  chart      = "rancher-backup"
  wait       = true
  
  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.storageClass"
    value = "longhorn"
  }

  depends_on = [helm_release.rancher_backup_crd]
}

resource "kubectl_manifest" "rancher_backup" {
  count      = var.profile == "PRIMARY" ? 1 : 0
  yaml_body  = data.kubectl_file_documents.rancher_backup.documents[0]
  depends_on = [helm_release.rancher_backup]
}

resource "helm_release" "rancher_extension_crd" {
  count            = var.profile == "PRIMARY" ? 1 : 0
  name             = "ui-plugin-operator-crd"
  namespace        = "cattle-ui-plugin-system"
  repository       = "https://charts.rancher.io"
  chart            = "ui-plugin-operator-crd"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_extension" {
  count      = var.profile == "PRIMARY" ? 1 : 0
  name       = "ui-plugin-operator"
  namespace  = "cattle-ui-plugin-system"
  repository = "https://charts.rancher.io"
  chart      = "ui-plugin-operator"
  wait       = true
  depends_on = [helm_release.rancher_extension_crd]
}

resource "helm_release" "rancher_elemental_crd" {
  count            = var.profile == "PRIMARY" ? 1 : 0
  name             = "elemental-operator-crds"
  namespace        = "cattle-elemental-system"
  chart            = "oci://registry.suse.com/rancher/elemental-operator-crds-chart"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_elemental" {
  count      = var.profile == "PRIMARY" ? 1 : 0
  name       = "elemental-operator"
  namespace  = "cattle-elemental-system"
  chart      = "oci://registry.suse.com/rancher/elemental-operator-chart"
  wait       = true
  depends_on = [helm_release.rancher_elemental_crd]
}

resource "time_sleep" "wait_5_minutes" {
  count           = var.profile == "PRIMARY" ? 1 : 0
  create_duration = "5m"
  depends_on      = [helm_release.rancher]
}