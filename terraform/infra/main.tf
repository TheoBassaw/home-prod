terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.16.1"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = ">= 1.4.0"
    }
  }

  backend "s3" {}
}

provider "tailscale" {
  tailnet             = var.tailnet
  oauth_client_id     = var.tailscale_client_id
  oauth_client_secret = var.tailscale_client_secret
}

provider "oci" {}

module "tailscale" {
  source = "./tailscale"
}

module "oracle_cloud" {
  source               = "./oracle-cloud"
  compartment_id       = var.compartment_id
  domain               = var.domain
  flux_git_url         = var.flux_git_url
  ssh_private_key_path = var.ssh_private_key_path
}