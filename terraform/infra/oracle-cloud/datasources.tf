data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.control_plane_cluster.id
}