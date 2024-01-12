resource "zerotier_network" "overlay" {
  name = var.OVERLAY_NAME

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.OVERLAY_NETWORK, 100)
    end   = cidrhost(var.OVERLAY_NETWORK, 250)
  }

  route {
    target = var.OVERLAY_NETWORK
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  name = var.INGRESS_NAME

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.INGRESS_NETWORK, 10)
    end   = cidrhost(var.INGRESS_NETWORK, 250)
  }

  route {
    target = var.INGRESS_NETWORK
  }

  route {
    target = var.AGGREGATE_NETWORK
    via    = var.INGRESS_VIP
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}