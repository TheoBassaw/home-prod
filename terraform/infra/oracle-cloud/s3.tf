resource "oci_objectstorage_bucket" "kube_configs" {
  compartment_id = var.compartment_id
  name           = "kube-configs"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  versioning     = "Enabled"
}

resource "oci_objectstorage_object" "oke_kubeconfig" {
  bucket    = oci_objectstorage_bucket.kube_configs.name
  content   = data.oci_containerengine_cluster_kube_config.kube_config.content
  namespace = data.oci_objectstorage_namespace.namespace.namespace
  object    = "kamaji-cluster.yaml"
}