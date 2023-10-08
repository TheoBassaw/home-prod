data "cloudinit_config" "route_controller_1" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-controller.tftpl", {
      "hostname"        = "route-controller-1"
      "domain"          = var.domain
      "zt_public"       = zerotier_identity.route_controller_1.public_key
      "zt_private"      = zerotier_identity.route_controller_1.private_key
      "zt_mesh_network" = zerotier_network.router_overlay.id
    })
  }
}

data "cloudinit_config" "route_controller_2" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-controller.tftpl", {
      "hostname"        = "route-controller-2"
      "domain"          = var.domain
      "zt_public"       = zerotier_identity.route_controller_2.public_key
      "zt_private"      = zerotier_identity.route_controller_2.private_key
      "zt_mesh_network" = zerotier_network.router_overlay.id
    })
  }
}

data "cloudinit_config" "ingress_1" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-ingress.tftpl", {
      "hostname"           = "ingress-1"
      "domain"             = var.domain
      "zt_public"          = zerotier_identity.ingress_1.public_key
      "zt_private"         = zerotier_identity.ingress_1.private_key
      "zt_mesh_network"    = zerotier_network.router_overlay.id
      "zt_ingress_network" = zerotier_network.ingress.id
    })
  }
}

data "cloudinit_config" "ingress_2" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-ingress.tftpl", {
      "hostname"           = "ingress-2"
      "domain"             = var.domain
      "zt_public"          = zerotier_identity.ingress_2.public_key
      "zt_private"         = zerotier_identity.ingress_2.private_key
      "zt_mesh_network"    = zerotier_network.router_overlay.id
      "zt_ingress_network" = zerotier_network.ingress_backup.id
    })
  }
}