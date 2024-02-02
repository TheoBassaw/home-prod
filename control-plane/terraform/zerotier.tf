resource "zerotier_network" "overlay" {
  name = var.network.overlay_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.network.overlay_network, 100)
    end   = cidrhost(var.network.overlay_network, 250)
  }

  route {
    target = var.network.overlay_network
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "route_controllers" {
  for_each = var.route_controllers
}

resource "zerotier_member" "route_controllers" {
  for_each = var.route_controllers

  name           = each.value.host_name
  member_id      = zerotier_identity.route_controllers[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.zerotier_ip]
}

resource "zerotier_identity" "ingresses" {
  for_each = var.ingresses
}

resource "zerotier_member" "ingresses" {
  for_each = var.ingresses

  name           = each.value.host_name
  member_id      = zerotier_identity.ingresses[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.zerotier_ip]
}