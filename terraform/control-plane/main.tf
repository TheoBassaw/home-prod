terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.7.0"
    }
  }
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  region       = var.region
  private_key  = var.oci_api_key
}

module "k8s" {
  source              = "./k8s"
  config_path         = local_file.kubeconfig.filename
  seal_key_id         = oci_kms_key.vault_key.id
  crypto_endpoint     = oci_kms_vault.prod_vault.crypto_endpoint
  management_endpoint = oci_kms_vault.prod_vault.management_endpoint
  compartment_id      = var.tenancy_ocid
  cf_token            = var.cf_token
}