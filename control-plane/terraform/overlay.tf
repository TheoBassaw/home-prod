resource "zerotier_network" "overlay" {
  name = local.network.overlay.name

  route {
    target = local.network.overlay.network
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  name = local.network.ingress.name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(local.network.ingress.network, 10)
    end   = cidrhost(local.network.ingress.network, 250)
  }

  route {
    target = local.network.ingress.network
  }

  route {
    target = local.network.overlay.aggregate
    via    = local.network.ingress.vip
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}