resource "zerotier_network" "overlay" {
  name = var.overlay_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.overlay_network, 100)
    end   = cidrhost(var.overlay_network, 250)
  }

  route {
    target = var.overlay_network
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  name = var.ingress_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.ingress_network, 10)
    end   = cidrhost(var.ingress_network, 250)
  }

  route {
    target = var.ingress_network
  }

  route {
    target = var.aggregate_network
    via    = var.ingress_vip
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}