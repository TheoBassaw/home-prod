variable "config_path" {
  type = string
}

variable "deploy_key" {
  type      = string
  sensitive = true
}
