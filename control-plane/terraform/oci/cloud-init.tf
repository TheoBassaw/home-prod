data "cloudinit_config" "route_controller" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata-controller.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "route-controller-1" : "route-controller-2"
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.route_controller.public_key
      "zt_private" = zerotier_identity.route_controller.private_key
      "zt_network" = var.zerotier_network
      "tsig_key"   = var.tsig_key
    })
  }
}

data "cloudinit_config" "nginx" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "nginx-1" : "nginx-2"
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.nginx.public_key
      "zt_private" = zerotier_identity.nginx.private_key
      "zt_network" = var.zerotier_network
    })
  }
}

data "cloudinit_config" "personal_devices" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "Personal-Devices" : "Personal-Devices-Backup"
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.personal_devices.public_key
      "zt_private" = zerotier_identity.personal_devices.private_key
      "zt_network" = var.zerotier_network
    })
  }
}

data "cloudinit_config" "gitlab_runner" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "gitlab-runner-1" : "gitlab-runner-2"
      "domain"     = var.domain
      "zt_public"  = zerotier_identity.gitlab_runner.public_key
      "zt_private" = zerotier_identity.gitlab_runner.private_key
      "zt_network" = var.zerotier_network
    })
  }
}