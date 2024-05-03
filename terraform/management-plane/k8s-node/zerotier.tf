resource "zerotier_identity" "k8s_node" {}

resource "zerotier_member" "k8s_node" {
  name           = var.host_name
  member_id      = zerotier_identity.k8s_node.id
  network_id     = var.zt_overlay_network
  ip_assignments = [var.zt_overlay_ip]
}