data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "longhorn_backup" {
  compartment_id = var.tenancy_ocid
  name           = "longhorn_backup"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
}