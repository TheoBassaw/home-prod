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

variable "compartment_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "flux_git_url" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}