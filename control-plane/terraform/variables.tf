variable "OCI_CONFIG_PROFILE_PRIMARY" {
  type    = string
  default = "PRIMARY"
}

variable "OCI_CONFIG_PROFILE_SECONDARY" {
  type    = string
  default = "SECONDARY"
}

variable "OCI_CONFIG_PRIMARY" {
  type = object({
    compartment_id = string
    user_ocid      = string
    region         = string
    image_ocid     = string
  })

  default = {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
    user_ocid      = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
    region         = "us-ashburn-1"
    image_ocid     = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
  }
}

variable "OCI_CONFIG_SECONDARY" {
  type = object({
    compartment_id = string
    user_ocid      = string
    region         = string
    image_ocid     = string
  })

  default = {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
    user_ocid      = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
    region         = "us-ashburn-1"
    image_ocid     = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
  }
}

variable "ZEROTIER_CENTRAL_TOKEN" {
  type      = string
  sensitive = true
}

variable "AGGREGATE_NETWORK" {
  type    = string
  default = "10.30.0.0/16"
}

variable "OVERLAY_NETWORK" {
  type    = string
  default = "10.30.0.0/24"
}

variable "OVERLAY_NAME" {
  type    = string
  default = "Overlay"
}

variable "INGRESS_NETWORK" {
  type    = string
  default = "10.30.1.0/24"
}

variable "INGRESS_NAME" {
  type    = string
  default = "Ingress"
}

variable "INGRESS_VIP" {
  type    = string
  default = "10.30.1.1"
}

variable "DOMAIN" {
  type    = string
  default = "paradisenetworkz.com"
}

variable "PRIMARY_HOSTS" {
  type = map(object({
    availability_domain = number
    host_name           = string
    type                = string
  }))

  default = {
    route_controller_1 = {
      availability_domain = 0
      host_name           = "route-controller-1"
      type                = "route_controller"
    }
    route_controller_2 = {
      availability_domain = 1
      host_name           = "route-controller-2"
      type                = "route_controller"
    }
    k8s_control_1 = {
      availability_domain = 1
      host_name           = "k8s-control-1"
      type                = "k8s_server"
    }
  }
}

variable "SECONDARY_HOSTS" {
  type = map(object({
    availability_domain = number
    host_name           = string
    type                = string
  }))

  default = {
    k8s_control_2 = {
      availability_domain = 0
      host_name           = "k8s-control-2"
      type                = "k8s_server"
    }
    k8s_control_3 = {
      availability_domain = 2
      host_name           = "k8s-control-3"
      type                = "k8s_server"
    }
  }
}