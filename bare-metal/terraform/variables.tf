locals {
  hypervisors = {
    home_1 = {
      overlay_ip = "10.30.0.10",
      host_name = "hypervisor-home-1",
    },
    anghelo_1 = {
      overlay_ip = "10.30.0.11",
      host_name = "hypervisor-anghelo-1"
    }
  }
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "DOPPLER_TOKEN" {
  type      = string
  sensitive = true
}

variable "ZT_ROUTER_OVERLAY" {
  type      = string
  sensitive = true
}