resource "helm_release" "vault" {
  count            = var.profile == "SECONDARY" ? 1 : 0
  name             = "vault"
  namespace        = "vault"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.25.0"
  wait             = true
  values           = [templatefile("${path.module}/templates/vault-values.yaml", {
    vault_url           = "vault-prod.paradisenetworkz.com",
    seal_key_id         = var.vault_key_id,
    crypto_endpoint     = var.crypto_endpoint,
    management_endpoint = var.management_endpoint
  })]
}