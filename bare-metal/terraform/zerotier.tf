data "zerotier_network" "router_overlay" {
  id = var.ZT_ROUTER_OVERLAY
}

resource "zerotier_identity" "hypervisors" {
  for_each = local.hypervisors
}

resource "zerotier_member" "hypervisors" {
  for_each = local.hypervisors

  name           = each.value.host_name
  member_id      = zerotier_identity.hypervisors[each.key].id
  network_id     = data.zerotier_network.router_overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "doppler_secret" "hypervisors" {
  for_each = local.hypervisors

  project = "hypervisors"
  config = "prd"
  name = upper("HYPERVISOR_${each.key}_ZT")
  value = yamlencode({
    "zt_public": zerotier_identity.hypervisors[each.key].public_key
    "zt_private": zerotier_identity.hypervisors[each.key].private_key
    "zt_network": data.zerotier_network.router_overlay.id
    "host_name": each.value.host_name
  })
}