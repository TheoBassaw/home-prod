terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.7.0"
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

module "oci_primary" {
  source         = "./oci"
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  region         = "us-ashburn-1"
  user_ocid      = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
  profile        = "PRIMARY"
  providers = {
    oci = oci.primary
  }
}

module "oci_secondary" {
  source         = "./oci"
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
  region         = "us-ashburn-1"
  user_ocid      = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
  profile        = "SECONDARY"
  providers = {
    oci = oci.secondary
  }
}

module "k8s_primary" {
  source              = "./k8s"
  kube_config         = module.oci_primary.kube_config
  profile             = "PRIMARY"
  cf_token            = var.cf_token
  s3_access_key       = module.oci_primary.s3_access_key
  s3_secret_key       = module.oci_primary.s3_secret_key
  s3_endpoint         = module.oci_primary.s3_endpoint
  s3_url              = "s3://${module.oci_primary.bucket}@us-ashburn-1/"
  vault_key_id        = module.oci_primary.vault_key_id
  crypto_endpoint     = module.oci_primary.crypto_endpoint
  management_endpoint = module.oci_primary.management_endpoint
}

module "k8s_secondary" {
  source              = "./k8s"
  kube_config         = module.oci_secondary.kube_config
  profile             = "SECONDARY"
  cf_token            = var.cf_token
  s3_access_key       = module.oci_secondary.s3_access_key
  s3_secret_key       = module.oci_secondary.s3_secret_key
  s3_endpoint         = module.oci_secondary.s3_endpoint
  s3_url              = "s3://${module.oci_secondary.bucket}@us-ashburn-1/"
  vault_key_id        = module.oci_secondary.vault_key_id
  crypto_endpoint     = module.oci_secondary.crypto_endpoint
  management_endpoint = module.oci_secondary.management_endpoint
}