resource "zerotier_identity" "route_controller" {}

resource "zerotier_identity" "nginx" {}

resource "zerotier_identity" "personal_devices" {}

resource "zerotier_identity" "gitlab_runner" {}

resource "zerotier_member" "route_controller" {
  name           = var.profile == "PRIMARY" ? "route-controller-1" : "route-controller-2"
  member_id      = zerotier_identity.route_controller.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.1" : "10.30.0.2"]
}

resource "zerotier_member" "nginx" {
  name           = var.profile == "PRIMARY" ? "nginx-1" : "nginx-2"
  member_id      = zerotier_identity.nginx.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.3" : "10.30.0.4"]
}

resource "zerotier_member" "personal_devices" {
  name           = var.profile == "PRIMARY" ? "Personal-Devices" : "Personal-Devices-Backup"
  member_id      = zerotier_identity.personal_devices.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.5" : "10.30.0.6"]
}

resource "zerotier_member" "devices" {
  name           = var.profile == "PRIMARY" ? "Personal-Devices" : "Personal-Devices-Backup"
  member_id      = zerotier_identity.personal_devices.id
  network_id     = var.zerotier_network_devices
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.1.1" : "10.30.1.2"]
}

resource "zerotier_member" "gitlab_runner" {
  name           = var.profile == "PRIMARY" ? "gitlab-runner-1" : "gitlab-runner-2"
  member_id      = zerotier_identity.gitlab_runner.id
  network_id     = var.zerotier_network
  ip_assignments = [var.profile == "PRIMARY" ? "10.30.0.7" : "10.30.0.8"]
}