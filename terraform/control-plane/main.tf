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
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "oci" {
  alias               = "primary"
  config_file_profile = "PRIMARY"
}

provider "oci" {
  alias               = "secondary"
  config_file_profile = "SECONDARY"
}

provider "zerotier" {
  zerotier_central_token = var.zerotier_token
}

module "oci_primary" {
  source           = "./oci"
  
  compartment_id   = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  profile          = "PRIMARY"
  zerotier_network = zerotier_network.router_overlay.id
  tsig_key         = var.tsig_key

  providers = {
    oci = oci.primary
  }
}

module "oci_secondary" {
  source           = "./oci"

  compartment_id   = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
  profile          = "SECONDARY"
  zerotier_network = zerotier_network.router_overlay.id
  tsig_key         = var.tsig_key

  providers = {
    oci = oci.secondary
  }
}