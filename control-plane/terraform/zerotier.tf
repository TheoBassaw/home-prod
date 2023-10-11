resource "zerotier_network" "router_overlay" {
  name = "Router Overlay"

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "10.30.0.10"
    end   = "10.30.0.250"
  }

  route {
    target = "10.30.0.0/24"
  }

  route {
    target = "10.30.1.0/24"
    via    = "10.30.0.3"
  }

  route {
    target = "10.30.2.0/24"
    via    = "10.30.0.4"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  name = "Ingress"

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "10.30.1.10"
    end   = "10.30.1.250"
  }

  route {
    target = "10.30.1.0/24"
  }

  route {
    target = "10.30.0.0/16"
    via    = "10.30.1.1"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress_backup" {
  name = "Ingress Backup"

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "10.30.2.10"
    end   = "10.30.2.250"
  }

  route {
    target = "10.30.2.0/24"
  }

  route {
    target = "10.30.0.0/16"
    via    = "10.30.2.1"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_identity" "route_controller_1" {}
resource "zerotier_identity" "route_controller_2" {}
resource "zerotier_identity" "ingress_1" {}
resource "zerotier_identity" "ingress_2" {}

resource "zerotier_member" "route_controller_1" {
  name           = "route-controller-1"
  member_id      = zerotier_identity.route_controller_1.id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.1"]
}

resource "zerotier_member" "route_controller_2" {
  name           = "route-controller-2"
  member_id      = zerotier_identity.route_controller_2.id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.2"]
}

resource "zerotier_member" "ingress_1" {
  name           = "ingress-1"
  member_id      = zerotier_identity.ingress_1.id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.3"]
}

resource "zerotier_member" "ingress_2" {
  name           = "ingress-2"
  member_id      = zerotier_identity.ingress_2.id
  network_id     = zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.4"]
}

resource "zerotier_member" "ingress_router" {
  name           = "ingress-1"
  member_id      = zerotier_identity.ingress_1.id
  network_id     = zerotier_network.ingress.id
  ip_assignments = ["10.30.1.1"]
}

resource "zerotier_member" "ingress_router_backup" {
  name           = "ingress-2"
  member_id      = zerotier_identity.ingress_2.id
  network_id     = zerotier_network.ingress_backup.id
  ip_assignments = ["10.30.2.1"]
}

resource "doppler_secret" "zt_mesh_network" {
  project = "control-plane"
  config = "prd"
  name = "ZT_MESH_NETWORK"
  value = zerotier_network.router_overlay.id
}