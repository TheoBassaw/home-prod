locals {
  primary = {
    "route_reflector" = { ip = "10.30.0.1" }
    "dns_server"      = { ip = "10.30.0.3" }
  }

  secondary = {
    "route_reflector" = { ip = "10.30.0.2" }
    "dns_server"      = { ip = "10.30.0.4" }
  }
}

variable "cf_token" {
  type      = string
  sensitive = true
}

variable "zerotier_token" {
  type      = string
  sensitive = true
}