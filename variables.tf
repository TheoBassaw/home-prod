locals {
  route_reflectors = {
    "router_reflector_1" = { ip = "10.30.16.1", availability_domain = "wkHw:US-ASHBURN-AD-1", hostname = "router-reflector-1" }
    "router_reflector_2" = { ip = "10.30.16.2", availability_domain = "wkHw:US-ASHBURN-AD-2", hostname = "router-reflector-2" }
  }

  dns_servers = {
    "dns_server_1" = { ip = "10.30.16.3", availability_domain = "wkHw:US-ASHBURN-AD-1", hostname = "dns-server-1" }
    "dns_server_2" = { ip = "10.30.16.4", availability_domain = "wkHw:US-ASHBURN-AD-3", hostname = "dns-server-2" }
  }
}

variable "zerotier_central_token" {
  type      = string
  sensitive = true
}

variable "oci_api_key" {
  type      = string
  sensitive = true
}

variable "tenancy_ocid" {
  type      = string
  default   = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "image_shape" {
  type      = string
  default   = "VM.Standard.A1.Flex"
}

variable "source_type" {
  type      = string
  default   = "image"
}

variable "subnet_id" {
  type      = string
  default   = "ocid1.subnet.oc1.iad.aaaaaaaat5p4xp3la23x2k3mgs6m5pag52j4zohbprtd2gria5d76siwrrra"
}

variable "domain" {
  type      = string
  default   = "paradisenetworkz.com"
}