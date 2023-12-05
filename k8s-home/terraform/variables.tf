locals {
  network           = yamldecode(var.NETWORK)
  route_controllers = yamldecode(var.ROUTE_CONTROLLERS)
  k8s_hosts         = yamldecode(var.K8S_HOSTS)
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "DOMAIN" {
  type = string
}

variable "USER_PASSWORD" {
  type      = string
  sensitive = true
}

variable "ZT_OVERLAY" {
  type      = string
  sensitive = true
}

variable "ROUTE_CONTROLLERS" {
  type = string
}

variable "NETWORK" {
  type = string
}

variable "K8S_HOSTS" {
  type = string
}