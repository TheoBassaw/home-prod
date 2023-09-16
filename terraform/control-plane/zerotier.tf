resource "zerotier_network" "router_overlay_network" {
  name = "Router Overlay Network"

  assign_ipv4 {
    zerotier = true
  }

  route {
    target = "10.30.0.0/24"
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}