terraform {
  required_providers {
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
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/hypervisors"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/hypervisors/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/hypervisors/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "zerotier" {
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN
}