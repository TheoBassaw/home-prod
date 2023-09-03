output "kube_config" {
  value      = data.oci_containerengine_cluster_kube_config.control_cluster_kube_config.content
  depends_on = [oci_containerengine_node_pool.arm_node_pool]
}

output "s3_access_key" {
  value     = base64encode(oci_identity_customer_secret_key.longhorn_secret_key.id)
  sensitive = true
}

output "s3_secret_key" {
  value     = base64encode(oci_identity_customer_secret_key.longhorn_secret_key.key)
  sensitive = true
}

output "s3_endpoint" {
  value     = base64encode("https://${data.oci_objectstorage_namespace.namespace.namespace}.compat.objectstorage.${var.region}.oraclecloud.com")
  sensitive = true
}

output "region" {
  value = var.region
}

output "bucket" {
  value = oci_objectstorage_bucket.longhorn_backup.name
}