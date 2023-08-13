variable "config_path" {
  type = string
}

variable "ssh_deploy_key" {
  type      = string
  sensitive = true
}
