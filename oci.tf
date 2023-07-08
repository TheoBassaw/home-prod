data "oci_core_images" "ubuntu_hardened" {
    compartment_id = var.tenancy_ocid
    display_name   = "Ubuntu-22.04-Hardened Image"
}

data "cloudinit_config" "route_reflectors" {
  for_each = local.route_reflectors

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/userdata.yaml", {
      "hostname"     = each.value.hostname
      "fqdn"         = "${each.value.hostname}.${var.domain}"
      "zerotier_public_key"  = zerotier_identity.route_reflectors[each.key].public_key
      "zerotier_private_key" = zerotier_identity.route_reflectors[each.key].private_key
      "zerotier_network_id"  = zerotier_network.router-overlay-network.id
    })
  }
}

data "cloudinit_config" "dns_servers" {
  for_each = local.dns_servers

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/userdata.yaml", {
      "hostname"     = each.value.hostname
      "fqdn"         = "${each.value.hostname}.${var.domain}"
      "zerotier_public_key"  = zerotier_identity.dns_servers[each.key].public_key
      "zerotier_private_key" = zerotier_identity.dns_servers[each.key].private_key
      "zerotier_network_id"  = zerotier_network.router-overlay-network.id
    })
  }
}

resource "oci_core_instance" "route_reflectors" {
  for_each = local.route_reflectors

  availability_domain = each.value.availability_domain
  compartment_id      = var.tenancy_ocid
  display_name        = each.key
  shape               = var.image_shape

  metadata = {
    user_data = data.cloudinit_config.route_reflectors[each.key].rendered
  }

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

  metadata = {
    user_data = data.cloudinit_config.dns_servers[each.key].rendered
  }

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