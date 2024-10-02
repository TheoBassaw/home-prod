terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }
}

provider "oci" {
  user_ocid        = var.user_ocid
  tenancy_ocid     = var.compartment_id
  fingerprint      = var.fingerprint
  region           = var.region
  private_key_path = var.private_key_path
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

resource "oci_kms_vault" "s3_vault" {
  compartment_id = var.compartment_id
  display_name   = "s3_vault"
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "s3_encryption" {
  compartment_id      = var.compartment_id
  display_name        = "s3_encryption"
  management_endpoint = oci_kms_vault.s3_vault.management_endpoint
  protection_mode     = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_identity_policy" "s3_policy" {
  compartment_id = var.compartment_id
  description    = "S3 Policy"
  name           = "s3_policy"
  statements     = [
    "Allow service objectstorage-${var.region} to use keys in compartment id ${var.compartment_id} where target.key.id = '${oci_kms_key.s3_encryption.id}'"
  ]
}

resource "oci_objectstorage_bucket" "tf_states" {
  compartment_id = var.compartment_id
  name           = "tf-states"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  kms_key_id     = oci_kms_key.s3_encryption.id
  versioning     = "Enabled"
}