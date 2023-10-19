locals {
  route_controllers = {
    route_controller_1 = {
      overlay_ip = "10.30.0.1",
      host_name = "route-controller-1",
      availability_domain = 0
    },
    route_controller_2 = {
      overlay_ip = "10.30.0.2",
      host_name = "route-controller-2"
      availability_domain = 1
    }
  }
  ingresses = {
    ingress_1 = {
      overlay_ip = "10.30.0.3",
      ingress_ip = "10.30.1.1",
      host_name = "ingress-1",
      availability_domain = 0
      ingress_network = { name = "Ingress", network = "10.30.1.0/24" }
    },
    ingress_2 = {
      overlay_ip = "10.30.0.4",
      ingress_ip = "10.30.1.2",
      host_name = "ingress-1",
      availability_domain = 1
      ingress_network = { name = "Ingress Backup", network = "10.30.2.0/24" }
    }
  }
}

variable "prod_network_aggregation" {
  type    = string
  default = "10.30.0.0/16"
}

variable "router_overlay_network" {
  type    = string
  default = "10.30.0.0/24"
}

variable "router_overlay_name" {
  type    = string
  default = "Router Overlay"
}

variable "oci_config_profile" {
  type    = string
  default = "DEFAULT"
}

variable "oci_default_network" {
  type    = string
  default = "10.0.0.0/24"
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

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "DOPPLER_TOKEN" {
  type      = string
  sensitive = true
}