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
  project = "bare-metal"
  config  = "prd"
  name    = "HYPERVISORS"
  value   = yamlencode({ for k,v in local.hypervisors: k => {
    "host_name": v.host_name
    "overlay_ip": v.overlay_ip
    "zt_public": zerotier_identity.hypervisors[k].public_key
    "zt_private": zerotier_identity.hypervisors[k].private_key
    "zt_network": data.zerotier_network.router_overlay.id
  }})
}

resource "local_file" "hypervisor_inventory" {
  filename = "${path.module}/../ansible/inventory/hypervisors"

  content  = templatefile("${path.module}/templates/hypervisors.tftpl", {
    inventory = local.hypervisors
  })
}