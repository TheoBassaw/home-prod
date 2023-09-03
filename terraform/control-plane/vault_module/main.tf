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
    oci = {
      source  = "oracle/oci"
      version = "5.7.0"
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

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  region           = var.region
  private_key_path = var.private_key_path
}

resource "helm_release" "vault" {
  name             = "vault"
  namespace        = "vault"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.25.0"
  wait             = true
  values           = [templatefile("${path.module}/templates/vault-values.yaml", {
    vault_url           = var.vault_url,
    seal_key_id         = oci_kms_key.vault_key.id,
    crypto_endpoint     = oci_kms_vault.prod_vault.crypto_endpoint,
    management_endpoint = oci_kms_vault.prod_vault.management_endpoint
  })]
}