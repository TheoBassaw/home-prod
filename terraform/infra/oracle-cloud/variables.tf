locals {
  vcn_cidr_ipv4 = "10.0.0.0/23"
  vcn_cidr_ipv6 = "fc00::/64"
}

variable "compartment_id" {
  type = string
}

variable "domain" {
  type = string
}