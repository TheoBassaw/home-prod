data "kubectl_file_documents" "http_issuer" {
  content = file("${path.module}/manifests/http-issuer.yaml")
}

data "kubectl_file_documents" "linkerd_ca" {
  content = file("${path.module}/manifests/linkerd-ca.yaml")
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

resource "helm_release" "trust_manager" {
  name       = "trust-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "trust-manager"
  version    = "0.5.0"
  wait       = true
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "http_issuer" {
  for_each   = data.kubectl_file_documents.http_issuer.manifests
  yaml_body  = each.value
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "linkerd_ca" {
  for_each   = data.kubectl_file_documents.linkerd_ca.manifests
  yaml_body  = each.value
  wait       = true
  depends_on = [helm_release.trust_manager]
}

resource "helm_release" "linkerd_crds" {
  name       = "linkerd-crds"
  namespace  = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-crds"
  wait       = true
  depends_on = [kubectl_manifest.linkerd_ca]
}

resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  namespace  = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-control-plane"
  wait       = true

  set {
    name  = "proxyInit.iptablesMode"
    value = "nft"
  }

  set {
    name  = "identity.externalCA"
    value = true
  }

  set {
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }

  depends_on = [
    helm_release.trust_manager,
    helm_release.linkerd_crds
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  wait             = true
  create_namespace = true

  set {
    name  = "controller.podAnnotations.linkerd\\.io/inject"
    value = "enabled"
  }

  set {
    name  = "controller.service.annotations.oci\\.oraclecloud\\.com/load-balancer-type"
    value = "nlb"
  }

  depends_on = [helm_release.linkerd_control_plane]
}