resource "oci_kms_vault" "prod_vault" {
  compartment_id = var.tenancy_ocid
  display_name   = "Production Vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "test_key" {
  compartment_id      = var.tenancy_ocid
  display_name        = "Vault Unseal Key"
  management_endpoint = oci_kms_vault.prod_vault.management_endpoint
  protection_mode     = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}