terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = "1.4.2"
    }
  }
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/k8s-home"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/k8s-home/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/k8s-home/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "zerotier" {
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}