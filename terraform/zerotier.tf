resource "zerotier_network" "router_overlay_network" {
  name = var.overlay_name

  assign_ipv4 {
    zerotier = true
  }

  route {
    target = var.overlay_cidr
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "route_reflectors" {
  for_each = local.route_reflectors
}

resource "zerotier_member" "route_reflectors" {
  for_each = local.route_reflectors

  name           = each.key
  member_id      = zerotier_identity.route_reflectors[each.key].id
  network_id     = zerotier_network.router_overlay_network.id
  ip_assignments = [each.value.ip]
}

resource "zerotier_identity" "control_servers" {
  for_each = local.control_servers
}

resource "zerotier_member" "control_servers" {
  for_each = local.control_servers

  name           = each.key
  member_id      = zerotier_identity.control_servers[each.key].id
  network_id     = zerotier_network.router_overlay_network.id
  ip_assignments = [each.value.ip]
}