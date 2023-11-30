data "zerotier_network" "overlay" {
  id = var.ZT_OVERLAY
}

resource "zerotier_identity" "k8s" {
  for_each = local.k8s
}

resource "zerotier_member" "k8s" {
  for_each = local.k8s

  name           = each.value.host_name
  member_id      = zerotier_identity.k8s[each.key].id
  network_id     = data.zerotier_network.overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "local_file" "k8s" {
  for_each = local.k8s

  filename = "${path.module}/../userdata/${each.value.host_name}"
  content  = templatefile("${path.module}/templates/autoinstall-userdata.tftpl", {
    "host_name": each.value.host_name
    "domain": var.domain
    "zt_public": zerotier_identity.k8s[each.key].public_key
    "zt_private": zerotier_identity.k8s[each.key].private_key
    "zt_network": data.zerotier_network.overlay.id
    "user_password": var.USER_PASSWORD
  })
}

resource "local_file" "k8s_inventory" {
  filename = "${path.module}/../ansible/inventory/k8s-home"
  content  = templatefile("${path.module}/templates/k8s-home.tftpl", {
    inventory = local.k8s
  })
}