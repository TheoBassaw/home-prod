variable "compartment_id" {
  type = string
}

variable "config_path" {
  type = string
}

variable "rancher_url" {
  type    = string
  default = "rancher-prod.paradisenetworkz.com"
}

variable "bootstrapPassword" {
  type    = string
  default = "bootstrap"
}

variable "cf_token" {
  type      = string
  sensitive = true
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

variable "region" {
  type = string
}

variable "bucket" {
  type = string
}