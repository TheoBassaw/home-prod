locals {
  compartment_id       = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
  ssh_private_key_path = "~/.ssh/ansible"
  flux_git_url         = "ssh://git@gitlab.com/TheDarkBrotherhood/infrastructure.git"
}

variable "tailnet" {
  type = string
}

variable "tailscale_client_id" {
  type      = string
  sensitive = true
}

variable "tailscale_client_secret" {
  type      = string
  sensitive = true
}