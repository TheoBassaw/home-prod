variable "oci_config_profile" {
  type    = string
  default = "PRIMARY"
}

variable "compartment_id" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "user_ocid" {
  type    = string
  default = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "image_ocid" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
}

variable "oci_default_network" {
  type    = string
  default = "10.0.0.0/24"
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "source_type" {
  type    = string
  default = "image"
}

variable "zerotier_central_token" {
  type      = string
  sensitive = true
}

variable "aggregate_network" {
  type    = string
  default = "10.30.0.0/16"
}

variable "overlay_network" {
  type    = string
  default = "10.30.0.0/24"
}

variable "overlay_name" {
  type    = string
  default = "Overlay"
}

variable "ingress_network" {
  type    = string
  default = "10.30.1.0/24"
}

variable "ingress_name" {
  type    = string
  default = "Ingress"
}

variable "ingress_vip" {
  type    = string
  default = "10.30.1.1"
}

variable "domain" {
  type    = string
  default = "paradisenetworkz.com"
}

variable "route_controllers" {
  type = map(object({
    availability_domain = number
    host_name           = string
  }))

  default = {
    route_controller_1 = {
      availability_domain = 0
      host_name           = "route-controller-1"
    }
    route_controller_2 = {
      availability_domain = 1
      host_name           = "route-controller-2"
    }
  }
}

variable "ingress_controllers" {
  type = map(object({
    availability_domain = number
    host_name           = string
  }))

  default = {
    ingress_controller_1 = {
      availability_domain = 0
      host_name           = "ingress-controller-1"
    }
    ingress_controller_2 = {
      availability_domain = 1
      host_name           = "ingress-controller-2"
    }
  }
}