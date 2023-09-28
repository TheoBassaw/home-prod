resource "zerotier_network" "router_overlay" {
  name = "Router Overlay"

  assign_ipv4 {
    zerotier = true
  }

  route {
    target = "10.30.0.0/24"
  }

  route {
    target = "10.30.1.0/24"
    via    = "10.30.0.7"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "personal_devices" {
  name = "Personal Devices"

  assign_ipv4 {
    zerotier = true
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