locals {
  hypervisors = {
    home_1 = {
      overlay_ip = "10.30.0.10",
      host_name  = "hypervisor-home-1",
    },
    home_2 = {
      overlay_ip = "10.30.0.11",
      host_name  = "hypervisor-home-2",
    },
    home_3 = {
      overlay_ip = "10.30.0.12",
      host_name  = "hypervisor-home-3",
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