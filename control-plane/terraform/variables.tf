locals {
  network = {
    overlay = {
      name    = "Overlay"
      network = "10.30.0.0/24"
    }
    ingress = {
      name    = "Ingress"
      network = "10.30.1.0/24"
      vip     = "10.30.1.1"
    }
  }
  route_controllers = {
    route_controller_1 = {
      availability_domain = 0
      host_name           = "route-controller-1"
      overlay_ip          = cidrhost(local.network.overlay.network, 1)
      ingress_ip          = cidrhost(local.network.ingress.network, 2)
      type                = "route_controller"
    }
    route_controller_2 = {
      availability_domain = 1
      host_name           = "route-controller-2"
      overlay_ip          = cidrhost(local.network.overlay.network, 2)
      ingress_ip          = cidrhost(local.network.ingress.network, 3)
      type                = "route_controller"
    }
  }
  k8s_hosts = {
    k8s_control_1 = {
      availability_domain = 1
      overlay_ip          = cidrhost(local.network.overlay.network, 10)
      host_name           = "k8s-control-1"
      type                = "k8s_server"
    }
    k8s_control_2 = {
      availability_domain = 0
      overlay_ip          = cidrhost(local.network.overlay.network, 11)
      host_name           = "k8s-control-2"
      type                = "k8s_server"
    }
    k8s_control_3 = {
      availability_domain = 2
      overlay_ip          = cidrhost(local.network.overlay.network, 12)
      host_name           = "k8s-control-3"
      type                = "k8s_server"
    }
  }
  domain                 = "paradisenetworkz.com"
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}

variable "oci_config_profile_primary" {
  type    = string
  default = "PRIMARY"
}

variable "oci_config_profile_secondary" {
  type    = string
  default = "SECONDARY"
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}