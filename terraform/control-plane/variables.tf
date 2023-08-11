variable "oci_api_key" {
  type      = string
  sensitive = true
}

variable "tenancy_ocid" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "user_ocid" {
  type    = string
  default = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
}

variable "fingerprint" {
  type    = string
  default = "df:25:a5:50:84:e4:36:d3:53:56:4a:7e:a0:fa:73:dd"
}

variable "domain" {
  type    = string
  default = "internl.paradisenetworkz.com"
}