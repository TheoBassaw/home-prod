variable "kube_config" {
  type = string
}

variable "cf_token" {
  type      = string
  sensitive = true
}

variable "s3_url" {
  type = string
}

variable "s3_access_key" {
  type      = string
  sensitive = true
}

variable "s3_secret_key" {
  type      = string
  sensitive = true
}

variable "s3_endpoint" {
  type      = string
  sensitive = true
}

variable "profile" {
  type = string
}

variable "vault_key_id" {
  type = string
}

variable "crypto_endpoint" {
  type = string
}

variable "management_endpoint" {
  type = string
}