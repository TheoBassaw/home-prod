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

  }

  backend "remote" {
    hostname     = "app.terraform.io"
	organization = "home-prod"
	workspaces {
	  name = "oracle-cloud-k8s"
	}
  }
}

data "oci_containerengine_clusters" "boostrap_cluster" {
  compartment_id = var.compartment_id
  name           = "bootstrap-cluster"
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = data.oci_containerengine_clusters.boostrap_cluster.clusters[0].id
}

provider "oci" {}

provider "flux" {
  kubernetes = {
    cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content).clusters[0].cluster.certificate-authority-data)
    host                   = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content).clusters[0].cluster.server
    exec                   = {
      api_version = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content).users[0].user.exec.apiVersion
      command     = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content).users[0].user.exec.command
      args        = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content).users[0].user.exec.args

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

resource "flux_bootstrap_git" "bootstrap" {
  path = "bootstrap-cluster/k8s"
}
