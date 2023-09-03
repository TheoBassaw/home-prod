resource "oci_kms_vault" "prod_vault" {
  compartment_id = var.tenancy_ocid
  display_name   = "Production Vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "vault_key" {
  compartment_id      = var.tenancy_ocid
  display_name        = "Vault Unseal Key"
  management_endpoint = oci_kms_vault.prod_vault.management_endpoint
  protection_mode     = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_identity_dynamic_group" "control_cluster" {
  compartment_id = var.tenancy_ocid
  name           = "control-cluster"
  description    = "K8S Cluster"
  matching_rule  = "instance.compartment.id = '${var.tenancy_ocid}'"
}

resource "oci_identity_policy" "tenant_policy" {
  compartment_id = var.tenancy_ocid
  description    = "Tenant Access"
  name           = "tenant-access"
  statements     = ["allow dynamic-group ${oci_identity_dynamic_group.control_cluster.name} to manage all-resources IN TENANCY"]
}