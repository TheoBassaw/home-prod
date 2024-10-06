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

module "flux" {
  source = "../flux"
  kube_config          = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)
  ssh_private_key_path = var.ssh_private_key_path
  flux_git_url         = var.flux_git_url
  cluster_name         = "management-cluster"
}