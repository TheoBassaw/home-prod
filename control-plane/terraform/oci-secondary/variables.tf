variable "oci_default_network" {
  type    = string
  default = "10.0.1.0/24"
}

variable "compartment_id" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
}

variable "user_ocid" {
  type    = string
  default = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
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

variable "zt_overlay_id" {
  type = string
}

variable "zt_ingress_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "route_controllers" {
  type = map(object({
    availability_domain = number
    host_name           = string
    overlay_ip          = string
    ingress_ip          = string
    type                = string
  }))
}

variable "network" {
  type = object({
    overlay = object({
      name      = string
      network   = string
      aggregate = string
    })
    ingress = object({
      name    = string
      network = string
      vip     = string
    })
  })
}

variable "k8s_hosts" {
  type = map(object({
    availability_domain = number
    overlay_ip          = string
    host_name           = string
    type                = string
  }))
}