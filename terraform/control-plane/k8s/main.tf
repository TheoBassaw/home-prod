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
      source = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

provider "kubectl" {
  config_path = var.config_path
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${var.rancher_url}"
  insecure  = true
  bootstrap = true
}