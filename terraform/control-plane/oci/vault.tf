resource "oci_kms_vault" "prod_vault" {
  count          = var.profile == "SECONDARY" ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "Production Vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "vault_key" {
  count               = var.profile == "SECONDARY" ? 1 : 0
  compartment_id      = var.compartment_id
  display_name        = "Vault Unseal Key"
  management_endpoint = oci_kms_vault.prod_vault[0].management_endpoint
  protection_mode     = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_identity_dynamic_group" "control_cluster" {
  compartment_id = var.compartment_id
  name           = "control-cluster"
  description    = "K8S Cluster"
  matching_rule  = "instance.compartment.id = '${var.compartment_id}'"
}

resource "oci_identity_policy" "tenant_policy" {
  compartment_id = var.compartment_id
  description    = "Tenant Access"
  name           = "tenant-access"
  statements     = ["allow dynamic-group ${oci_identity_dynamic_group.control_cluster.name} to manage all-resources IN TENANCY"]
}