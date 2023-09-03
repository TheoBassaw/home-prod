terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/control-plane/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

module "oci" {
  source           = "./oci"
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  region           = "us-ashburn-1"
  user_ocid        = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
  fingerprint      = "df:25:a5:50:84:e4:36:d3:53:56:4a:7e:a0:fa:73:dd"
  app              = "rancher"
  private_key_path = "${path.root}/secrets/oci_main.pem"
}

module "k8s_bootstrap" {
  source        = "./k8s-bootstrap"
  config_path   = module.oci.kube_config
  cf_token      = var.cf_token
  region        = module.oci.region
  bucket        = module.oci.bucket
  s3_access_key = module.oci.s3_access_key
  s3_secret_key = module.oci.s3_secret_key
  s3_endpoint   = module.oci.s3_endpoint
}

module "rancher" {
  source      = "./rancher"
  config_path = module.k8s_bootstrap.kube_config
  rancher_url = "rancher-prod.paradisenetworkz.com"
}