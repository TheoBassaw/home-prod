resource "zerotier_network" "router_overlay" {
  name = var.router_overlay_name

  route {
    target = var.router_overlay_network
  }

  dynamic "route"{
    for_each = local.ingresses
    
    content {
      target = route.value.ingress_network.network
      via    = route.value.overlay_ip
    }
  }

  dns {
    domain = var.domain
    servers = [for route_controller in local.route_controllers: route_controller.overlay_ip]
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  for_each = local.ingresses

  name = each.value.ingress_network.name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(each.value.ingress_network.network, 10)
    end   = cidrhost(each.value.ingress_network.network, 250)
  }

  route {
    target = each.value.ingress_network.network
  }

  route {
    target = var.prod_network_aggregation
    via    = each.value.ingress_ip
  }

  dns {
    domain = var.domain
    servers = [for route_controller in local.route_controllers: route_controller.overlay_ip]
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "route_controllers" {
  for_each = local.route_controllers
}

resource "zerotier_identity" "ingresses" {
  for_each = local.ingresses
}

resource "zerotier_member" "route_controllers" {
  for_each = local.route_controllers

  name           = each.value.host_name
  member_id      = zerotier_identity.route_controllers[each.key].id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "zerotier_member" "ingresses" {
  for_each = local.ingresses

  name           = each.value.host_name
  member_id      = zerotier_identity.ingresses[each.key].id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "zerotier_member" "ingress_router" {
  for_each = local.ingresses

  name           = each.value.host_name
  member_id      = zerotier_identity.ingresses[each.key].id
  network_id     = zerotier_network.ingress[each.key].id
  ip_assignments = [each.value.ingress_ip]
}

resource "doppler_secret" "router_overlay" {
  project = "control-plane"
  config = "prd"
  name = "ZT_ROUTER_OVERLAY"
  value = zerotier_network.router_overlay.id
}