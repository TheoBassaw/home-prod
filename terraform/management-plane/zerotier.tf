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