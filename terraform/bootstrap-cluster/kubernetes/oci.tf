data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

data "oci_objectstorage_bucket" "kubeconfigs" {
  name      = "kube-configs"
  namespace = data.oci_objectstorage_namespace.namespace.namespace
}

data "oci_objectstorage_object" "oke_kubeconfig" {
  bucket    = data.oci_objectstorage_bucket.kubeconfigs.name
  namespace = data.oci_objectstorage_namespace.namespace.namespace
  object    = "bootstrap-cluster.yaml"
}