variable "tenancy" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "availability_domain" {
  type    = string
  default = "wkHw:US-ASHBURN-AD-1"
}

variable "base_image_ocid" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
}

variable "image_name" {
  type    = string
  default = "Ubuntu-22.04-Hardened Image"
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "subnet_ocid" {
  type    = string
  default = "ocid1.subnet.oc1.iad.aaaaaaaaqt7w3xfuisgmamsmoerbfuwrmurnbt2krvabbezeka7ff6kl7xwq"
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

variable "key_file" {
  type    = string
  default = "../oci_api_key.pem"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ocpus" {
  type    = number
  default = 1
}

variable "memory_in_gbs" {
  type    = number
  default = 1
}