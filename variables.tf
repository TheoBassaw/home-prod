locals {
  route_reflectors = {
    "router_reflector_1" = { ip = "10.30.16.1" }
    "router_reflector_2" = { ip = "10.30.16.2" }
  }

  dns_servers = {
    "dns_server_1" = { ip = "10.30.16.3" }
    "dns_server_2" = { ip = "10.30.16.4" }
  }
}

variable "zerotier_central_token" {
  type      = string
  sensitive = true
}