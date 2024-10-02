terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = ">= 1.4.0"
    }
  }
}

locals {
  cluster_ca_certificate = base64decode(var.kube_config.clusters[0].cluster.certificate-authority-data)
  host                   = var.kube_config.clusters[0].cluster.server
  exec = {
    api_version = var.kube_config.users[0].user.exec.apiVersion
    command     = var.kube_config.users[0].user.exec.command
    args        = var.kube_config.users[0].user.exec.args
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


resource "flux_bootstrap_git" "bootstrap" {
  path = "k8s/clusters/kamaji-cluster"
}