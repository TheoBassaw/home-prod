variable "compartment_id" {
  type = string
}

variable "profile" {
  type = string
}

variable "zerotier_network" {
  type = string
}

variable "domain" {
  type    = string
  default = "paradisenetworkz.com"
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "source_type" {
  type    = string
  default = "image"
}

variable "image_ocid" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
}

variable "tsig_key" {
  type      = string
  sensitive = true
}