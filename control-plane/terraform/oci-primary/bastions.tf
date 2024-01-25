resource "zerotier_identity" "bastions" {
  for_each = var.bastions
}

resource "zerotier_member" "bastions" {
  for_each = var.bastions

  name       = each.value.host_name
  member_id  = zerotier_identity.bastions[each.key].id
  network_id = var.zt_overlay_id
}


resource "zerotier_member" "ingresses" {
  for_each = var.bastions

  name       = each.value.host_name
  member_id  = zerotier_identity.bastions[each.key].id
  network_id = var.zt_bastion_id
}

data "cloudinit_config" "bastions" {
  for_each = var.bastions
  
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-bastion.tftpl", {
      "host_name"  = each.value.host_name
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.bastions[each.key].public_key
      "zt_private" = zerotier_identity.bastions[each.key].private_key
      "zt_overlay" = var.zt_overlay_id
      "zt_bastion" = var.zt_bastion_id
    })
  }
}

resource "oci_core_instance" "bastions" {
  for_each = var.bastions

  compartment_id      = var.oci.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.oci.image_shape
  display_name        = each.value.host_name
  freeform_tags       = {
    "type": "bastion"
  }

  metadata = {
    user_data = data.cloudinit_config.bastions[each.key].rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    source_id   = var.oci.image_ocid
    source_type = var.oci.source_type
  }
}