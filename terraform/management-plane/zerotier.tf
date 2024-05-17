resource "zerotier_network" "overlay" {
  name = "Mesh Overlay"

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "10.30.8.100"
    end   = "10.30.8.250"
  }

  route {
    target = "10.30.8.0/24"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  for_each = local.ingress_routers

  name = each.value.ingress_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = each.value.start_ip
    end   = each.value.end_ip
  }

  route {
    target = each.value.ingress_address
  }

  route {
    target = "10.30.0.0/16"
    via    = each.value.zerotier_ip[1]
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "ingress" {
  for_each = local.ingress_routers
}

resource "zerotier_member" "ingress_overlay" {
  for_each = local.ingress_routers

  name           = each.value.host_name
  member_id      = zerotier_identity.ingress[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.zerotier_ip[0]]
}

resource "zerotier_member" "ingress" {
  for_each = local.ingress_routers

  name           = each.value.host_name
  member_id      = zerotier_identity.ingress[each.key].id
  network_id     = zerotier_network.ingress[each.key].id
  ip_assignments = [each.value.zerotier_ip[1]]
}