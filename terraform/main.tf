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
  user_ocid    = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
  fingerprint  = "df:25:a5:50:84:e4:36:d3:53:56:4a:7e:a0:fa:73:dd"
  region       = "us-ashburn-1"
  private_key  = var.OCI_API_KEY
}