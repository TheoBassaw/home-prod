locals {
  route_reflectors = {
    "route_reflector_1" = { ip = "10.30.16.1", availability_domain = "wkHw:US-ASHBURN-AD-1", hostname = "route-reflector-1" }
    "route_reflector_2" = { ip = "10.30.16.2", availability_domain = "wkHw:US-ASHBURN-AD-2", hostname = "route-reflector-2" }
  }

  control_servers = {
    "control_server_1" = { ip = "10.30.16.3", availability_domain = "wkHw:US-ASHBURN-AD-1", hostname = "control-server-1", clusterCIDR = "10.30.18.0/23", serviceCIDR = "10.30.20.0/23" }
    "control_server_2" = { ip = "10.30.16.4", availability_domain = "wkHw:US-ASHBURN-AD-3", hostname = "control-server-2", clusterCIDR = "10.30.22.0/23", serviceCIDR = "10.30.24.0/23" }
  }
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "OCI_API_KEY" {
  type      = string
  sensitive = true
}

variable "tenancy_ocid" {
  type    = string
  default = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
}

variable "image_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "source_type" {
  type    = string
  default = "image"
}

variable "subnet_id" {
  type    = string
  default = "ocid1.subnet.oc1.iad.aaaaaaaaqt7w3xfuisgmamsmoerbfuwrmurnbt2krvabbezeka7ff6kl7xwq"
}

variable "domain" {
  type    = string
  default = "internl.paradisenetworkz.com"
}