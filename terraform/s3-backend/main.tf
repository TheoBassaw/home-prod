terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }
}

locals {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  region         = "us-ashburn-1"
}

provider "oci" {}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = local.compartment_id
}

resource "oci_objectstorage_bucket" "tf_states" {
  compartment_id = local.compartment_id
  name           = "tf-states"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  versioning     = "Enabled"
}