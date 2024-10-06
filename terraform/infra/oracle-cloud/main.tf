terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = ">= 1.4.0"
    }
  }
}

output "kube_config" {
  value = data.oci_containerengine_cluster_kube_config.kube_config.content
  depends_on = [oci_containerengine_node_pool.node_pool]
}