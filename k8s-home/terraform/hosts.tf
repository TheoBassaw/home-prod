data "zerotier_network" "overlay" {
  id = var.ZT_OVERLAY
}

resource "zerotier_identity" "k8s_hosts" {
  for_each = local.k8s_hosts
}

resource "zerotier_member" "k8s_hosts" {
  for_each = local.k8s_hosts

  name           = each.value.host_name
  member_id      = zerotier_identity.k8s_hosts[each.key].id
  network_id     = data.zerotier_network.overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "local_file" "k8s_hosts" {
  for_each = local.k8s_hosts

  filename = "${path.module}/../userdata/${each.value.host_name}"
  content  = templatefile("${path.module}/templates/autoinstall-userdata.tftpl", {
    "host_name": each.value.host_name
    "domain": var.DOMAIN
    "zt_public": zerotier_identity.k8s_hosts[each.key].public_key
    "zt_private": zerotier_identity.k8s_hosts[each.key].private_key
    "zt_overlay": data.zerotier_network.overlay.id
    "user_password": var.USER_PASSWORD
    "overlay_ip": each.value.overlay_ip
    "vip": each.value.vip
    "asn": local.network.asn
    "overlay_network": local.network.overlay.network
    "aggregate_network": local.network.aggregate
    "route_controllers": join(",", [for k,v in local.route_controllers: v.overlay_ip])
  })
}

resource "local_file" "meta_data" {
  content  = ""
  filename = "${path.module}/../userdata/meta-data"
}

resource "local_file" "k8s_inventory" {
  filename = "${path.module}/../ansible/inventory/k8s-hosts"
  content  = templatefile("${path.module}/templates/k8s-hosts.tftpl", {
    inventory = local.k8s_hosts
  })
}