resource "vultr_instance" "ingress_routers" {
  for_each = local.ingress_routers

  label       = each.value.host_name
  enable_ipv6 = true
  plan        = "vc2-1c-1gb"
  region      = "ewr"
  os_id       = 1743 # Ubuntu 22.04 LTS
  tags        = ["ingress_router"]

  user_data = templatefile("${path.root}/templates/ingress.tftpl", {
    "host_name"  = each.value.host_name
    "domain"     = local.domain
    "zt_public"  = zerotier_identity.ingress_routers[each.key].public_key
    "zt_private" = zerotier_identity.ingress_routers[each.key].private_key
    "zt_overlay" = zerotier_network.overlay.id
    "zt_ingress" = zerotier_network.ingress.id
  })
}