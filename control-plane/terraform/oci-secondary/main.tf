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