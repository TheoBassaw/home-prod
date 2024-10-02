terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }
}

output "kube_config" {
  value = data.oci_containerengine_cluster_kube_config.kube_config.content
}