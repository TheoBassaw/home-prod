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
  config_file_profile = var.OCI_CONFIG_PROFILE_PRIMARY
  alias               = "primary"
}

provider "oci" {
  config_file_profile = var.OCI_CONFIG_PROFILE_SECONDARY
  alias               = "secondary"
}

provider "zerotier" {
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}

module "oci_primary" {
  source = "./oci-primary"
  
  compartment_id    = var.OCI_CONFIG_PRIMARY.compartment_id
  user_ocid         = var.OCI_CONFIG_PRIMARY.user_ocid
  region            = var.OCI_CONFIG_PRIMARY.region
  image_ocid        = var.OCI_CONFIG_PRIMARY.image_ocid
  zt_overlay_id     = zerotier_network.overlay.id
  zt_ingress_id     = zerotier_network.ingress.id
  domain            = var.DOMAIN
  hosts             = var.PRIMARY_HOSTS

  providers = {
    oci = oci.primary
  }
}

module "oci_secondary" {
  source = "./oci-secondary"

  compartment_id    = var.OCI_CONFIG_SECONDARY.compartment_id
  user_ocid         = var.OCI_CONFIG_SECONDARY.user_ocid
  region            = var.OCI_CONFIG_SECONDARY.region
  image_ocid        = var.OCI_CONFIG_SECONDARY.image_ocid
  zt_overlay_id     = zerotier_network.overlay.id
  zt_ingress_id     = zerotier_network.ingress.id
  domain            = var.DOMAIN
  hosts             = var.SECONDARY_HOSTS

  providers = {
    oci = oci.secondary
  }
}