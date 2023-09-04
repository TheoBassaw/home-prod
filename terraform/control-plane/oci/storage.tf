data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "longhorn_backup" {
  compartment_id = var.compartment_id
  name           = "longhorn_backup"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
}

resource "oci_identity_customer_secret_key" "longhorn_secret_key" {
  display_name = "longhorn-s3"
  user_id      = var.user_ocid
}