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

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "region" {
  type = string
}

variable "domain" {
  type = string
}