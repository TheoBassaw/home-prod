resource "zerotier_network" "ingress" {
  name = var.zt_network_name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = var.zt_start_ip
    end   = var.zt_end_ip
  }

  route {
    target = var.zt_network_address
  }

  route {
    target = "10.30.0.0/16"
    via    = var.zt_ingress_ip
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "ingress" {}

resource "zerotier_member" "overlay" {
  name           = var.host_name
  member_id      = zerotier_identity.ingress.id
  network_id     = var.zt_overlay_network
  ip_assignments = [var.zt_overlay_ip]
}

resource "zerotier_member" "ingress" {
  name           = var.host_name
  member_id      = zerotier_identity.ingress.id
  network_id     = zerotier_network.ingress.id
  ip_assignments = [var.zt_ingress_ip]
}