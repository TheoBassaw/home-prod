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
  alias = "primary"
}

provider "oci" {
  config_file_profile = var.oci_config_profile_secondary
  alias = "secondary"
}

provider "zerotier" {
  zerotier_central_token = var.zerotier_central_token
}

module "oci_primary" {
  source = "./oci-primary"

  oci               = var.oci_primary
  domain            = var.domain
  zt_overlay_id     = zerotier_network.overlay.id
  zt_bastion_id     = zerotier_network.bastion.id
  route_controllers = var.route_controllers
  bastions          = var.bastions

  providers = {
    oci = oci.primary
  }
}

module "oci_secondary" {
  source = "./oci-secondary"

  oci               = var.oci_secondary
  domain            = var.domain
  zt_overlay_id     = zerotier_network.overlay.id
  ingresses         = var.ingresses

  providers = {
    oci = oci.secondary
  }
}