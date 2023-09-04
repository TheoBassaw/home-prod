locals {
  route_reflectors = {
    "route_reflector_1" = { ip = "10.30.0.1" }
    "route_reflector_2" = { ip = "10.30.0.2" }
  }

  dns_servers = {
    "dns_server_1" = { ip = "10.30.0.3" }
    "dns_server_2" = { ip = "10.30.0.3" }
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