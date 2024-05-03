locals {
  domain                       = "paradisenetworkz.com"
  oci_config_profile_primary   = "PRIMARY"
  oci_config_profile_secondary = "SECONDARY"
  oci_config_profile_tertiary  = "TERTIARY"
  compartment_id_primary       = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  compartment_id_secondary     = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
  compartment_id_tertiary      = "ocid1.tenancy.oc1..aaaaaaaaw5fv7owkogdfpk4tzop3yodqcrm6ioo6yoie4f7ihglzrifcreja"

  nodes = {
    k8s_master_1 = {
      type                = "k8s_master"
      availability_domain = 0
      host_name           = "k8s-master-1"
      zerotier_ip         = ["10.30.8.5"]
    },
    k8s_master_2 = {
      type                = "k8s_master"
      availability_domain = 0
      host_name           = "k8s-master-2"
      zerotier_ip         = ["10.30.8.6"]
    },
    k8s_master_3 = {
      type                = "k8s_master"
      availability_domain = 2
      host_name           = "k8s-master-3"
      zerotier_ip         = ["10.30.8.7"]
    },
    ingress_router_1 = {
      type        = "ingress_router"
      host_name   = "ingress-router-1"
      zerotier_ip = ["10.30.8.1", "10.30.9.1"]
    },
    ingress_router_2 = {
      type        = "ingress_router"
      host_name   = "ingress-router-2"
      zerotier_ip = ["10.30.8.2", "10.30.10.1"]
    }
  }
}

variable "zerotier_central_token" {
  type      = string
  sensitive = true
}

variable "vultr_api_key" {
  type      = string
  sensitive = true
}