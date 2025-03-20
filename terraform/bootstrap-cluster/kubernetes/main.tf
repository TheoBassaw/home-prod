terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.1"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "home-prod"
    workspaces {
      name = "bootstrap-cluster-kubernetes"
    }
  }
}

provider "flux" {
  kubernetes = {
    cluster_ca_certificate = base64decode(yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).clusters[0].cluster.certificate-authority-data)
    host                   = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).clusters[0].cluster.server
    exec                   = {
      api_version = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.apiVersion
      command     = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.command
      args        = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.args

    }
  }
  git = {
    url = var.git_url
    ssh = {
      username    = "git"
      private_key = var.ssh_private_key
    }
  }
}

provider "kubectl" {
  cluster_ca_certificate = base64decode(yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).clusters[0].cluster.certificate-authority-data)
  host                   = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).clusters[0].cluster.server
  exec {
    api_version = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.apiVersion
    command     = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.command
    args        = yamldecode(data.oci_objectstorage_object.oke_kubeconfig.content).users[0].user.exec.args
  }
}

provider "oci" {}

resource "flux_bootstrap_git" "bootstrap" {
  path = "kubernetes/clusters/bootstrap-cluster"
}