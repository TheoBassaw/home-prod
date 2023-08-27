data "kubectl_file_documents" "rancher_backup" {
  content = file("${path.module}/manifests/rancher-backup.yaml")
}

resource "helm_release" "rancher" {
  name             = "rancher"
  namespace        = "cattle-system"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  create_namespace = true
  wait             = true
  values           = [templatefile("${path.module}/templates/rancher-values.yaml", {
    bootstrapPassword = var.bootstrapPassword,
    hostname          = var.rancher_url
  })]
}

resource "helm_release" "rancher_backup_crd" {
  name             = "rancher-backup-crd"
  namespace        = "cattle-resources-system"
  repository       = "https://charts.rancher.io"
  chart            = "rancher-backup-crd"
  wait             = true
  create_namespace = true
  depends_on = [helm_release.rancher]
}

resource "helm_release" "rancher_backup" {
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
  for_each   = data.kubectl_file_documents.rancher_backup.manifests
  yaml_body  = each.value
  depends_on = [helm_release.rancher_backup]
}

resource "helm_release" "rancher_monitoring_crd" {
  name             = "rancher-monitoring-crd"
  namespace        = "cattle-monitoring-system"
  repository       = "https://charts.rancher.io"
  chart            = "rancher-monitoring-crd"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_monitoring" {
  name       = "rancher-monitoring"
  namespace  = "cattle-monitoring-system"
  repository = "https://charts.rancher.io"
  chart      = "rancher-monitoring"
  wait       = true
  depends_on = [helm_release.rancher_monitoring_crd]
}

resource "helm_release" "rancher_extension_crd" {
  name             = "ui-plugin-operator-crd"
  namespace        = "cattle-ui-plugin-system"
  repository       = "https://charts.rancher.io"
  chart            = "ui-plugin-operator-crd"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_extension" {
  name       = "ui-plugin-operator"
  namespace  = "cattle-ui-plugin-system"
  repository = "https://charts.rancher.io"
  chart      = "ui-plugin-operator"
  wait       = true
  depends_on = [helm_release.rancher_extension_crd]
}

resource "helm_release" "rancher_elemental_crd" {
  name             = "elemental-operator-crds"
  namespace        = "cattle-elemental-system"
  chart            = "oci://registry.suse.com/rancher/elemental-operator-crds-chart"
  wait             = true
  create_namespace = true
  depends_on       = [helm_release.rancher]
}

resource "helm_release" "rancher_elemental" {
  name       = "elemental-operator"
  namespace  = "cattle-elemental-system"
  chart      = "oci://registry.suse.com/rancher/elemental-operator-chart"
  wait       = true
  depends_on = [helm_release.rancher_elemental_crd]
}

resource "rancher2_bootstrap" "admin" {
  provider         = rancher2.bootstrap
  initial_password = var.bootstrapPassword
  telemetry        = false
  depends_on       = [helm_release.rancher]
}