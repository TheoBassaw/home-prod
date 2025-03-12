terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
	  organization = "home-prod"
	  workspaces {
	    name = "oracle-cloud"
	  }
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.bootstrap-cluster.id
  depends_on = [oci_containerengine_node_pool.node_pool]
}

provider "oci" {}