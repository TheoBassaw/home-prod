data "cloudinit_config" "k8s_node" { 
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.root}/templates/userdata.tftpl", {
      "host_name"  = var.host_name
      "domain"     = var.domain
      "zt_public"  = var.zt_public_key
      "zt_private" = var.zt_private_key
      "zt_overlay" = var.zt_network
    })
  }
}

resource "oci_core_instance" "k8s_node" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain].name
  shape               = "VM.Standard.A1.Flex"
  display_name        = var.host_name
  freeform_tags       = {
    "type": var.host_type
  }

  metadata = {
    user_data = data.cloudinit_config.k8s_node.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.main_subnet.id
  }

  shape_config {
    memory_in_gbs = 24
    ocpus         = 4
  }

  source_details {
    source_id               = data.oci_core_images.ubuntu.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = 200
  }
}