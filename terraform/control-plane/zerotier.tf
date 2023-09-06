resource "zerotier_network" "router_overlay_network" {
  name = "Router Overlay Network"

  assign_ipv4 {
    zerotier = true
  }

  route {
    target = "10.30.0.0/24"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "primary" {
  for_each = local.primary
}

resource "zerotier_member" "primary" {
  for_each = local.primary

  name           = each.key
  member_id      = zerotier_identity.primary[each.key].id
  network_id     = zerotier_network.router_overlay_network.id
  ip_assignments = [each.value.ip]
}

resource "zerotier_identity" "secondary" {
  for_each = local.secondary
}

resource "zerotier_member" "secondary" {
  for_each = local.secondary

  name           = each.key
  member_id      = zerotier_identity.secondary[each.key].id
  network_id     = zerotier_network.router_overlay_network.id
  ip_assignments = [each.value.ip]
}