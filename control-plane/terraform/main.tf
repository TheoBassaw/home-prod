terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.7.0"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = "1.4.2"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.3.0"
    }
  }
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "oci" {
  config_file_profile = var.oci_config_profile_primary
  alias               = "primary"
}

provider "oci" {
  config_file_profile = var.oci_config_profile_secondary
  alias               = "secondary"
}

provider "zerotier" {
  zerotier_central_token = local.zerotier_central_token
}

module "oci_primary" {
  source = "./oci-primary"

  zt_overlay_id     = zerotier_network.overlay.id
  zt_ingress_id     = zerotier_network.ingress.id
  domain            = local.domain
  route_controllers = local.route_controllers
  network           = local.network
  k8s_hosts         = tomap({ k8s_control_1 = local.k8s_hosts.k8s_control_1 })

  providers = {
    oci = oci.primary
  }
}

module "oci_secondary" {
  source = "./oci-secondary"

  zt_overlay_id     = zerotier_network.overlay.id
  zt_ingress_id     = zerotier_network.ingress.id
  domain            = local.domain
  route_controllers = local.route_controllers
  network           = local.network
  k8s_hosts         = tomap({ 
    k8s_control_2 = local.k8s_hosts.k8s_control_2
    k8s_control_3 = local.k8s_hosts.k8s_control_3
  })

  providers = {
    oci = oci.secondary
  }
}