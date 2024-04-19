variable "compartment_id" {
  type = string
}

variable "availability_domain" {
  type = number
}

variable "domain" {
  type = string
}

variable "host_name" {
  type = string
}

variable "host_type" {
  type = string
}

variable "vcn_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}

variable "zt_network" {
  type = string
}

variable "zt_public_key" {
  type      = string
  sensitive = true
}

variable "zt_private_key" {
  type      = string
  sensitive = true
}