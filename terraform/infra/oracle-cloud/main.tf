terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = ">= 1.4.0"
    }
  }
}

provider "flux" {
  kubernetes = {
    cluster_ca_certificate = local.cluster_ca_certificate
    host = local.host
    exec = local.exec
  }
  git = {
    url = var.flux_git_url
    ssh = {
      username    = "git"
      private_key = file(var.ssh_private_key_path)
    }
  }
}