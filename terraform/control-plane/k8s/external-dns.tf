resource "helm_release" "external_dns_cf" {
  name       = "external-dns-cf"
  namespace  = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  wait       = true

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set_list {
    name  = "extraArgs"
    value = [
      "--exclude-target-net=10.30.16.0/24",
      "--txt-owner-id=external-dns-cf"
    ]
  }

  set {
    name  = "env[0].name"
    value = "CF_API_TOKEN"
  }

  set {
    name  = "env[0].value"
    value = var.cf_token
  }
}