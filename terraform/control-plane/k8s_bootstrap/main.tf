terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

locals {
  kube_config = yamldecode(var.kube_config)
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
    exec {
      api_version = local.kube_config.users[0].user.exec.apiVersion
      command     = local.kube_config.users[0].user.exec.command
      args        = concat(local.kube_config.users[0].user.exec.args, ["--profile", var.profile])
    }
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  exec {
    api_version = local.kube_config.users[0].user.exec.apiVersion
    command     = local.kube_config.users[0].user.exec.command
    args        = concat(local.kube_config.users[0].user.exec.args, ["--profile", var.profile])
  }
}