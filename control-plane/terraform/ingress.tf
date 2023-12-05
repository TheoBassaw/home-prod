resource "zerotier_identity" "ingresses" {
  for_each = local.ingresses
}

resource "zerotier_member" "ingresses_overlay" {
  for_each = local.ingresses

  name           = each.value.host_name
  member_id      = zerotier_identity.ingresses[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.overlay_ip]
}

resource "zerotier_member" "ingresses" {
  for_each = local.ingresses

  name           = each.value.host_name
  member_id      = zerotier_identity.ingresses[each.key].id
  network_id     = zerotier_network.ingress.id
  ip_assignments = [each.value.ingress_ip]
}

data "cloudinit_config" "ingresses" {
  for_each = local.ingresses

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-ingress.tftpl", {
      "host_name"         = each.value.host_name
      "domain"            = var.DOMAIN
      "zt_public"         = zerotier_identity.ingresses[each.key].public_key
      "zt_private"        = zerotier_identity.ingresses[each.key].private_key
      "zt_overlay"        = zerotier_network.overlay.id
      "zt_ingress"        = zerotier_network.ingress.id
      "overlay_ip"        = each.value.overlay_ip
      "asn"               = local.network.asn
      "overlay_network"   = local.network.overlay.network
      "aggregate_network" = local.network.aggregate
      "ingress_network"   = local.network.ingress.network
      "ingress_vip"       = local.network.ingress.vip
    })
  }
}

resource "oci_core_instance" "ingresses" {
  for_each = local.ingresses

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.shape
  display_name        = each.value.host_name
  freeform_tags       = {
    "type": each.value.type
  }

  metadata = {
    user_data = data.cloudinit_config.ingresses[each.key].rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}