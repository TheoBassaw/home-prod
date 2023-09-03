output "kube_config" {
  value = var.kube_config
  depends_on = [
    helm_release.external_dns_cf,
    helm_release.cert_manager,
    helm_release.ingress_nginx,
    helm_release.longhorn
  ]
}