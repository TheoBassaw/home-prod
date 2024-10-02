locals {
  kube_config            = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  host                   = local.kube_config.clusters[0].cluster.server
  exec = {
    api_version = local.kube_config.users[0].user.exec.apiVersion
    command     = local.kube_config.users[0].user.exec.command
    args        = local.kube_config.users[0].user.exec.args
  }
}

variable "compartment_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "flux_git_url" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}