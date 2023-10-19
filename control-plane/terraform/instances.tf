data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "cloudinit_config" "route_controllers" {
  for_each = local.route_controllers

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-controller.tftpl", {
      "host_name"         = each.value.host_name
      "domain"            = var.domain
      "zt_public"         = zerotier_identity.route_controllers[each.key].public_key
      "zt_private"        = zerotier_identity.route_controllers[each.key].private_key
      "zt_router_overlay" = zerotier_network.router_overlay.id
    })
  }
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
      "domain"            = var.domain
      "zt_public"         = zerotier_identity.ingresses[each.key].public_key
      "zt_private"        = zerotier_identity.ingresses[each.key].private_key
      "zt_router_overlay" = zerotier_network.router_overlay.id
      "zt_ingress_network" = zerotier_network.ingress[each.key].id
    })
  }
}

resource "oci_core_instance" "route_controllers" {
  for_each = local.route_controllers

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.shape
  display_name        = each.value.host_name
  freeform_tags       = {"type": "route_controller"}

  metadata = {
    user_data = data.cloudinit_config.route_controllers[each.key].rendered
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

resource "oci_core_instance" "ingresses" {
  for_each = local.ingresses

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.shape
  display_name        = each.value.host_name
  freeform_tags       = {"type": "ingress"}

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