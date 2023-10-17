data "zerotier_network" "router_overlay" {
  id = var.ZT_MESH_NETWORK
}

resource "zerotier_identity" "hypervisor_home_1" {}

resource "zerotier_member" "hypervisor_home_1" {
  name           = "hypervisor-home-1"
  member_id      = zerotier_identity.hypervisor_home_1.id
  network_id     = data.zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.10"]
}

resource "doppler_secret" "hypervisor_home_1" {
  project = "hypervisors"
  config = "prd"
  name = "HYPERVISOR_HOME_1_ZT"
  value = yamlencode({
    "zt_public": zerotier_identity.hypervisor_home_1.public_key
    "zt_private": zerotier_identity.hypervisor_home_1.private_key
    "zt_network": data.zerotier_network.router_overlay.id
  })
}

resource "zerotier_identity" "hypervisor_anghelo_1" {}

resource "zerotier_member" "hypervisor_anghelo_1" {
  name           = "hypervisor-anghelo-1"
  member_id      = zerotier_identity.hypervisor_anghelo_1.id
  network_id     = data.zerotier_network.router_overlay.id
  ip_assignments = ["10.30.0.11"]
}

resource "doppler_secret" "hypervisor_anghelo_1" {
  project = "hypervisors"
  config = "prd"
  name = "HYPERVISOR_ANGHELO_1_ZT"
  value = yamlencode({
    "zt_public": zerotier_identity.hypervisor_anghelo_1.public_key
    "zt_private": zerotier_identity.hypervisor_anghelo_1.private_key
    "zt_network": data.zerotier_network.router_overlay.id
  })
}