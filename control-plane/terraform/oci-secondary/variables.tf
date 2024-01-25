variable "oci" {
  type = object({
    compartment_id      = string
    user_ocid           = string
    region              = string
    image_ocid          = string
    oci_default_network = string
    image_shape         = string
    source_type         = string
  })
}

variable "zt_overlay_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "ingresses" {
  type = map(object({
    availability_domain = number
    host_name           = string
  }))
}