terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = "~> 1.4.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 5.3.0"
    }
  }
  backend "http" {}
}

provider "zerotier" {
  zerotier_central_token = var.ZEROTIER_CENTRAL_TOKEN
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  region       = var.region
  private_key  = var.OCI_API_KEY
}