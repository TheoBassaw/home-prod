resource "helm_release" "external_dns_oci" {
  name             = "external-dns-oci"
  namespace        = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  wait             = true
  create_namespace = true

  set {
    name  = "provider"
    value = "oci"
  }

  set_list {
    name  = "extraArgs"
    value = [
      "--oci-auth-instance-principal",
      "--oci-compartment-ocid=ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga",
      "--exclude-target-net=10.30.16.0/24",
      "--txt-owner-id=external-dns-oci"
    ]
  }
}

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
    value = "siqFcBXBL8C9VYRTlKKzhLifUsynlKGjEdnZlCrc"
  }

  depends_on = [helm_release.external_dns_oci]
}