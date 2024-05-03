resource "vultr_instance" "ingress" {
  label       = var.host_name
  enable_ipv6 = true
  plan        = "vc2-1c-1gb"
  region      = "ewr"
  os_id       = 1743 # Ubuntu 22.04 LTS
  tags        = [var.host_type]

  user_data = templatefile("${path.root}/templates/ingress.tftpl", {
    "host_name"  = var.host_name
    "domain"     = var.domain
    "zt_public"  = zerotier_identity.ingress.public_key
    "zt_private" = zerotier_identity.ingress.private_key
    "zt_overlay" = var.zt_overlay_network
    "zt_ingress" = zerotier_network.ingress.id
  })
}