data "oci_core_images" "ubuntu_hardened" {
    compartment_id = var.tenancy_ocid
    display_name   = "Ubuntu-22.04-Hardened Image"
}

resource "oci_core_instance" "route_reflectors" {
  for_each = local.route_reflectors

  availability_domain = each.value.availability_domain
  compartment_id      = var.tenancy_ocid
  display_name        = each.key
  shape               = var.image_shape

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  shape_config {
    memory_in_gbs = 8
    ocpus         = 1
  }

  source_details {
    source_type = var.source_type
    source_id   = data.oci_core_images.ubuntu_hardened.images[0].id
  }
}

resource "oci_core_instance" "dns_servers" {
  for_each = local.dns_servers

  availability_domain = each.value.availability_domain
  compartment_id      = var.tenancy_ocid
  display_name        = each.key
  shape               = var.image_shape

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    source_type = var.source_type
    source_id   = data.oci_core_images.ubuntu_hardened.images[0].id
  }
}