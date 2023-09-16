
resource "zerotier_identity" "route_reflector" {}

resource "zerotier_member" "route_reflector" {
  name           = var.profile == "PRIMARY" ? "route-reflector-1" : "route-reflector-2"
  member_id      = zerotier_identity.route_reflector.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.1" : "10.30.0.2"]
}