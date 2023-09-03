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
  private_key_path = "${path.root}/secrets/oci-main.pem"
}

module "oci_sec" {
  source           = "./oci"
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
  region           = "us-ashburn-1"
  user_ocid        = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
  fingerprint      = "e8:04:56:be:d8:24:6a:8f:e4:6a:b5:0e:4b:6c:aa:07"
  private_key_path = "${path.root}/secrets/oci-sec.pem"
}

module "k8s_bootstrap" {
  source        = "./k8s_bootstrap"
  kube_config   = module.oci.kube_config
  profile       = "DEFAULT"
  cf_token      = var.cf_token
  region        = module.oci.region
  bucket        = module.oci.bucket
  s3_access_key = module.oci.s3_access_key
  s3_secret_key = module.oci.s3_secret_key
  s3_endpoint   = module.oci.s3_endpoint
}

module "k8s_bootstrap_sec" {
  source        = "./k8s_bootstrap"
  kube_config   = module.oci_sec.kube_config
  profile       = "OCI-SEC"
  cf_token      = var.cf_token
  region        = module.oci_sec.region
  bucket        = module.oci_sec.bucket
  s3_access_key = module.oci_sec.s3_access_key
  s3_secret_key = module.oci_sec.s3_secret_key
  s3_endpoint   = module.oci_sec.s3_endpoint
}

module "rancher" {
  source      = "./rancher_module"
  kube_config = module.k8s_bootstrap.kube_config
  profile     = "DEFAULT"
  rancher_url = "rancher-prod.paradisenetworkz.com"
}

module "vault" {
  source           = "./vault_module"
  kube_config      = module.k8s_bootstrap_sec.kube_config
  profile          = "OCI-SEC"
  vault_url        = "vault-prod.paradisenetworkz.com"
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
  region           = "us-ashburn-1"
  user_ocid        = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
  fingerprint      = "e8:04:56:be:d8:24:6a:8f:e4:6a:b5:0e:4b:6c:aa:07"
  private_key_path = "${path.root}/secrets/oci-sec.pem"
}