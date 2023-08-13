terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.0.1"
    }
  }
}

provider "flux" {
  kubernetes = {
    config_path = var.config_path
  }
  git = {
    url = "ssh://git@gitlab.com/paradise-networkz/k8s.git"
    ssh = {
      username    = "git"
      private_key = var.ssh_deploy_key
    }
  }
}

resource "flux_bootstrap_git" "bootstrap_gitlab" {
  path = "clusters/control-cluster"
}