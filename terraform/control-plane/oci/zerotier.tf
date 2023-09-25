resource "zerotier_identity" "route_reflector" {}

resource "zerotier_identity" "dns_server" {}

resource "zerotier_identity" "nginx" {}

resource "zerotier_member" "route_reflector" {
  name           = var.profile == "PRIMARY" ? "route-reflector-1" : "route-reflector-2"
  member_id      = zerotier_identity.route_reflector.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.1" : "10.30.0.2"]
}

resource "zerotier_member" "dns_server" {
  name           = var.profile == "PRIMARY" ? "dns-server-1" : "dns-server-2"
  member_id      = zerotier_identity.dns_server.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.3" : "10.30.0.4"]
}

resource "zerotier_member" "nginx" {
  name           = var.profile == "PRIMARY" ? "nginx-1" : "nginx-2"
  member_id      = zerotier_identity.nginx.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.5" : "10.30.0.6"]
}