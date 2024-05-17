resource "vultr_firewall_group" "ingress" {
  description = "Ingress Firewall"
}

resource "vultr_firewall_rule" "ingress_https" {
  firewall_group_id = vultr_firewall_group.ingress.id
  protocol = "tcp"
  ip_type = "v4"
  subnet = "0.0.0.0"
  subnet_size = 0
  port = "443"
}

resource "vultr_firewall_rule" "ingress_ssh" {
  firewall_group_id = vultr_firewall_group.ingress.id
  protocol = "tcp"
  ip_type = "v4"
  subnet = "0.0.0.0"
  subnet_size = 0
  port = "22"
}

resource "vultr_firewall_rule" "ingress_zt" {
  firewall_group_id = vultr_firewall_group.ingress.id
  protocol = "udp"
  ip_type = "v4"
  subnet = "0.0.0.0"
  subnet_size = 0
  port = "9993"
}

resource "vultr_firewall_rule" "ingress_icmp" {
  firewall_group_id = vultr_firewall_group.ingress.id
  protocol = "icmp"
  ip_type = "v4"
  subnet = "0.0.0.0"
  subnet_size = 0
}

resource "vultr_instance" "ingress" {
  for_each = local.ingress_routers

  label             = each.value.host_name
  enable_ipv6       = true
  plan              = "vc2-1c-1gb"
  region            = "ewr"
  os_id             = 1743 # Ubuntu 22.04 LTS
  tags              = [each.value.type]
  firewall_group_id = vultr_firewall_group.ingress.id

  user_data = templatefile("${path.root}/templates/ingress.tftpl", {
    "host_name"  = each.value.host_name
    "domain"     = local.domain
    "zt_public"  = zerotier_identity.ingress[each.key].public_key
    "zt_private" = zerotier_identity.ingress[each.key].private_key
    "zt_overlay" = zerotier_network.overlay.id
    "zt_ingress" = zerotier_network.ingress[each.key].id
  })
}