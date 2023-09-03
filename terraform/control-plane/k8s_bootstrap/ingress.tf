data "kubectl_file_documents" "http_issuer" {
  content = file("${path.module}/manifests/http-issuer.yaml")
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.12.3"
  wait             = true
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "kubectl_manifest" "http_issuer" {
  for_each   = data.kubectl_file_documents.http_issuer.manifests
  yaml_body  = each.value
  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  wait             = true
  create_namespace = true

  set {
    name  = "controller.service.annotations.oci\\.oraclecloud\\.com/load-balancer-type"
    value = "nlb"
  }
}

resource "helm_release" "external_dns_cf" {
  name             = "external-dns-cf"
  namespace        = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  create_namespace = true
  wait             = true

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set_list {
    name  = "extraArgs"
    value = [
      "--exclude-target-net=10.0.0.0/23",
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