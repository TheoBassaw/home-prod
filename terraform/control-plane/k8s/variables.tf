variable "config_path" {
  type = string
}

variable "rancher_url" {
  type    = string
  default = "rancher-prod.paradisenetworkz.com"
}

variable "vault_url" {
  type    = string
  default = "vault-prod.paradisenetworkz.com"
}

variable "bootstrapPassword" {
  type    = string
  default = "bootstrap"
}

variable "seal_key_id" {
  type    = string
}

variable "crypto_endpoint" {
  type    = string
}

variable "management_endpoint" {
  type    = string
}