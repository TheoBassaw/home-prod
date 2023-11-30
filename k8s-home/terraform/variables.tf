locals {
  k8s = {
    k8s_home_1 = {
      overlay_ip = "10.30.0.10",
      host_name  = "k8s-home-1",
    },
    k8s_home_2 = {
      overlay_ip = "10.30.0.11",
      host_name  = "k8s-home-2",
    },
    k8s_home_3 = {
      overlay_ip = "10.30.0.12",
      host_name  = "k8s-home-3",
    }
  }
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "domain" {
  type    = string
  default = "paradisenetworkz.com"
}

variable "USER_PASSWORD" {
  type      = string
  sensitive = true
}

variable "ZT_OVERLAY" {
  type      = string
  sensitive = true
}