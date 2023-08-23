data "kubectl_file_documents" "namespace" {
  content = file("${path.module}/manifests/namespace.yaml")
}

resource "kubectl_manifest" "namespace" {
  for_each  = data.kubectl_file_documents.namespace.manifests
  yaml_body = each.value
}

resource "helm_release" "vault" {
  name       = "vault"
  namespace  = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.25.0"
  wait       = true
  values     = [templatefile("${path.module}/templates/vault-values.yaml", {
    vault_url = var.vault_url,
    seal_key_id         = var.seal_key_id,
    crypto_endpoint     = var.crypto_endpoint
    management_endpoint = var.management_endpoint
  })]
  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "rancher" {
  name       = "rancher"
  namespace  = "cattle-system"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  wait       = true
  values     = [templatefile("${path.module}/templates/rancher-values.yaml", {
    bootstrapPassword = var.bootstrapPassword,
    hostname          = var.rancher_url
  })]
  depends_on = [kubectl_manifest.namespace]
}

resource "rancher2_bootstrap" "admin" {
  provider         = rancher2.bootstrap
  initial_password = var.bootstrapPassword
  telemetry        = false
  depends_on       = [helm_release.rancher]
}