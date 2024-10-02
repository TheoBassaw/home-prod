data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.kamaji_cluster.id
  depends_on = [oci_containerengine_node_pool.node_pool]
}