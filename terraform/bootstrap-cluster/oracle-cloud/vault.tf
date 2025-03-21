resource "oci_kms_vault" "prod_vault" {
  compartment_id = var.compartment_id
  display_name   = "Production Vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "vault_key" {
  compartment_id      = var.compartment_id
  display_name        = "Vault Key"
  management_endpoint = oci_kms_vault.prod_vault.management_endpoint
  protection_mode     = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_vault_secret" "cf_token" {
  compartment_id = var.compartment_id
  vault_id       = oci_kms_vault.prod_vault.id
  key_id         = oci_kms_key.vault_key.id
  secret_name    = "cf-token"
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.cf_token)
  }
}

resource "oci_identity_dynamic_group" "bootstrap_cluster" {
  compartment_id = var.compartment_id
  name           = "bootstrap-cluster"
  description    = "bootstrap-cluster"
  matching_rule  = "instance.compartment.id = '${var.compartment_id}'"
}

resource "oci_identity_policy" "tenant_policy" {
  compartment_id = var.compartment_id
  description    = "tenant-access"
  name           = "tenant-access"
  statements     = ["allow dynamic-group ${oci_identity_dynamic_group.bootstrap_cluster.name} to manage all-resources IN TENANCY"]
}
