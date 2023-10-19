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
  config_file_profile = var.oci_config_profile
}

provider "zerotier" {
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN
}