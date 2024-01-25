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

resource "zerotier_network" "bastion" {
  name = var.network.bastion_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(var.network.bastion_network, 10)
    end   = cidrhost(var.network.bastion_network, 250)
  }

  route {
    target = var.network.bastion_network
  }

  route {
    target = var.network.aggregate_network
    via    = var.network.bastion_vip
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}