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
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.1.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
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

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${var.rancher_url}"
  insecure  = true
  bootstrap = true
}