variable "oci_config_profile_primary" {
  type    = string
  default = "PRIMARY"
}

variable "oci_config_profile_secondary" {
  type    = string
  default = "SECONDARY"
}

variable "zerotier_central_token" {
  type      = string
  sensitive = true
}

variable "domain" {
  type    = string
  default = "paradisenetworkz.com"
}

variable "oci_primary" {
  type = object({
    compartment_id      = string
    user_ocid           = string
    region              = string
    image_ocid          = string
    oci_default_network = string
    image_shape         = string
    source_type         = string
  })

  default = {
    compartment_id      = "ocid1.tenancy.oc1..aaaaaaaatnhzpultgkxreesu7vacfjiva2p4xnls45sfouvpjlvddd365rga"
    user_ocid           = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
    region              = "us-ashburn-1"
    image_ocid          = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
    oci_default_network = "10.0.0.0/24"
    image_shape         = "VM.Standard.A1.Flex"
    source_type         = "image"
  }
}

variable "oci_secondary" {
  type = object({
    compartment_id      = string
    user_ocid           = string
    region              = string
    image_ocid          = string
    oci_default_network = string
    image_shape         = string
    source_type         = string
  })

  default = {
    compartment_id      = "ocid1.tenancy.oc1..aaaaaaaajrjtbfnfcezp7qzuixww7xnars3fbpvvb3kw2hqti2la2rqlndbq"
    user_ocid           = "ocid1.user.oc1..aaaaaaaaglkblptu3vp7aj5zhcuaitztw2dgc2xekyipcrswipf73fsebzyq"
    region              = "us-ashburn-1"
    image_ocid          = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
    oci_default_network = "10.0.0.0/24"
    image_shape         = "VM.Standard.A1.Flex"
    source_type         = "image"
  }
}

variable "network" {
  type = object({
    aggregate_network = string
    overlay_network   = string
    overlay_name      = string
    bastion_network   = string
    bastion_name      = string
    bastion_vip       = string
  })

  default = {
    aggregate_network = "10.30.0.0/16"
    overlay_network   = "10.30.0.0/24"
    overlay_name      = "Overlay"
    bastion_network   = "10.30.1.0/24"
    bastion_name      = "Bastion"
    bastion_vip       = "10.30.1.1"
  }
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

variable "bastions" {
  type = map(object({
    availability_domain = number
    host_name           = string
  }))

  default = {
    bastion_1 = {
      availability_domain = 0
      host_name           = "bastion-1"
    }
    bastion_2 = {
      availability_domain = 1
      host_name           = "bastion-2"
    }
  }
}

variable "ingresses" {
  type = map(object({
    availability_domain = number
    host_name           = string
  }))

  default = {
    ingress_1 = {
      availability_domain = 0
      host_name           = "ingress-1"
    }
    ingress_2 = {
      availability_domain = 1
      host_name           = "ingress-2"
    }
  }
}