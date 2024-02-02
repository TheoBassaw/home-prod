data "cloudinit_config" "ingresses" {
  for_each = var.ingresses
  
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.root}/templates/userdata.tftpl", {
      "host_name"  = each.value.host_name
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.ingresses[each.key].public_key
      "zt_private" = zerotier_identity.ingresses[each.key].private_key
      "zt_overlay" = zerotier_network.overlay.id
    })
  }
}

resource "oci_core_instance" "ingresses" {
  for_each = var.ingresses

  compartment_id      = var.oci.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.oci.image_shape
  display_name        = each.value.host_name
  freeform_tags       = {
    "type": "ingress"
  }

  metadata = {
    user_data = data.cloudinit_config.ingresses[each.key].rendered
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