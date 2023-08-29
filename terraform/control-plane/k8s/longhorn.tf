data "kubectl_file_documents" "longhorn_s3_secret" {
  content = templatefile("${path.module}/templates/longhorn-s3-secret.yaml", {
    s3_access_key = var.s3_access_key
    s3_secret_key = var.s3_secret_key
    s3_endpoint   = var.s3_endpoint
  })
}

data "kubectl_file_documents" "longhorn_backup_job" {
  content = file("${path.module}/manifests/longhorn-backup.yaml")
}

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

  set {
    name  = "defaultSettings.backupTarget"
    value = "s3://${var.bucket}@${var.region}/"
  }

  set {
    name  = "defaultSettings.backupTargetCredentialSecret"
    value = "longhorn-s3-secret"
  }
}

resource "kubectl_manifest" "longhorn_s3_secret" {
  yaml_body = data.kubectl_file_documents.longhorn_s3_secret.documents[0]
  depends_on = [helm_release.longhorn]
}

resource "kubectl_manifest" "longhorn_backup_job" {
  for_each  = data.kubectl_file_documents.longhorn_backup_job.manifests
  yaml_body = each.value
  depends_on = [kubectl_manifest.longhorn_s3_secret]
}