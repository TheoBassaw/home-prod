variable "config_path" {
  type = string
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