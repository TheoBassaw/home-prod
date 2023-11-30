locals {
  route_controllers = {
    route_controller_1 = {
      overlay_ip          = "10.30.0.1",
      host_name           = "route-controller-1",
      availability_domain = 0,
      type                = "route_controller"
    },
    route_controller_2 = {
      overlay_ip          = "10.30.0.2",
      host_name           = "route-controller-2"
      availability_domain = 1,
      type                = "route_controller"
    }
  }
}

resource "zerotier_identity" "route_controllers" {
  for_each = local.route_controllers
}

resource "zerotier_member" "route_controllers" {
  for_each = local.route_controllers

  name           = each.value.host_name
  member_id      = zerotier_identity.route_controllers[each.key].id
  network_id     = zerotier_network.overlay.id
  ip_assignments = [each.value.overlay_ip]
}

data "cloudinit_config" "route_controllers" {
  for_each = local.route_controllers

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-route-controller.tftpl", {
      "host_name"         = each.value.host_name
      "domain"            = var.domain
      "zt_public"         = zerotier_identity.route_controllers[each.key].public_key
      "zt_private"        = zerotier_identity.route_controllers[each.key].private_key
      "zt_overlay"        = zerotier_network.overlay.id
      "overlay_ip"        = each.value.overlay_ip
      "asn"               = local.asn
      "overlay_network"   = local.overlay.network
      "aggregate_network" = local.aggregate
    })
  }
}

resource "oci_core_instance" "route_controllers" {
  for_each = local.route_controllers

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.shape
  display_name        = each.value.host_name
  freeform_tags       = {
    "type": each.value.type
  }

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