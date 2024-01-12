variable "oci_default_network" {
  type    = string
  default = "10.0.0.0/24"
}

variable "compartment_id" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "region" {
  type = string
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
  type = string
}

variable "zt_overlay_id" {
  type = string
}

variable "zt_ingress_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "hosts" {
  type = map(object({
    availability_domain = number
    host_name           = string
    type                = string
  }))
}