terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = ">= 1.4.2"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }
}