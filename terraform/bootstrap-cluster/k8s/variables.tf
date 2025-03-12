variable "compartment_id" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "git_url" {
  type    = string
  default = "ssh://git@github.com/TheoBassaw/home-prod.git"
}

variable "ssh_private_key" {
  type = string
}
