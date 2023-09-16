terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.7.0"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = "1.4.2"
    }
  }
}

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

output "bucket" {
  value = oci_objectstorage_bucket.longhorn_backup.name
}

output "vault_key_id" {
  value = try(oci_kms_key.vault_key[0].id, "")
}

output "crypto_endpoint" {
  value = try(oci_kms_vault.prod_vault[0].crypto_endpoint, "")
}

output "management_endpoint" {
  value = try(oci_kms_vault.prod_vault[0].management_endpoint, "")
}