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
  name = "Ingress Overlay"

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "10.30.9.10"
    end   = "10.30.9.250"
  }

  route {
    target = "10.30.9.0/24"
  }

  route {
    target = "10.30.0.0/16"
    via    = "10.30.9.3"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "k8s_nodes" {
  for_each = local.k8s_nodes
}

resource "zerotier_member" "k8s_nodes" {
  for_each = local.k8s_nodes

  name           = each.value.host_name
  member_id      = zerotier_identity.k8s_nodes[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.zerotier_ip[0]]
}

resource "zerotier_identity" "ingress_routers" {
  for_each = local.ingress_routers
}

resource "zerotier_member" "overlay_ingress_routers" {
  for_each = local.ingress_routers

  name           = each.value.host_name
  member_id      = zerotier_identity.ingress_routers[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.zerotier_ip[0]]
}

resource "zerotier_member" "ingress_routers" {
  for_each = local.ingress_routers

  name           = each.value.host_name
  member_id      = zerotier_identity.ingress_routers[each.key].id
  network_id     = zerotier_network.ingress.id
  ip_assignments = [each.value.zerotier_ip[1]]
}