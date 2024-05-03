terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = ">= 1.4.2"
    }
    vultr = {
      source  = "vultr/vultr"
      version = ">= 2.19.0"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/47476421/terraform/state/management-plane"
    lock_address   = "https://gitlab.com/api/v4/projects/47476421/terraform/state/management-plane/lock"
    lock_method    = "POST"
    unlock_address = "https://gitlab.com/api/v4/projects/47476421/terraform/state/management-plane/lock"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "oci" {
  config_file_profile = local.oci_config_profile_primary
  alias               = "primary"
}

provider "oci" {
  config_file_profile = local.oci_config_profile_secondary
  alias               = "secondary"
}

provider "oci" {
  config_file_profile = local.oci_config_profile_tertiary
  alias               = "tertiary"
}

provider "vultr" {
  api_key = var.vultr_api_key
}

provider "zerotier" {
  zerotier_central_token = var.zerotier_central_token
}


module "k8s_node_primary" {
  source = "./k8s-node"

  compartment_id      = local.compartment_id_primary
  availability_domain = local.nodes.k8s_master_1.availability_domain
  host_name           = local.nodes.k8s_master_1.host_name
  host_type           = local.nodes.k8s_master_1.type
  domain              = local.domain
  zt_overlay_network  = zerotier_network.overlay.id
  zt_overlay_ip       = local.nodes.k8s_master_1.zerotier_ip[0] 

  providers = {
    oci = oci.primary
  }
}

module "k8s_node_secondary" {
  source = "./k8s-node"

  compartment_id      = local.compartment_id_secondary
  availability_domain = local.nodes.k8s_master_2.availability_domain
  host_name           = local.nodes.k8s_master_2.host_name
  host_type           = local.nodes.k8s_master_2.type
  domain              = local.domain
  zt_overlay_network  = zerotier_network.overlay.id
  zt_overlay_ip       = local.nodes.k8s_master_2.zerotier_ip[0]

  providers = {
    oci = oci.secondary
  }
}

module "k8s_node_tertiary" {
  source = "./k8s-node"

  compartment_id      = local.compartment_id_tertiary
  availability_domain = local.nodes.k8s_master_3.availability_domain
  host_name           = local.nodes.k8s_master_3.host_name
  host_type           = local.nodes.k8s_master_3.type
  domain              = local.domain
  zt_overlay_network  = zerotier_network.overlay.id
  zt_overlay_ip       = local.nodes.k8s_master_3.zerotier_ip[0]

  providers = {
    oci = oci.tertiary
  }
}

module "ingress_router_primary" {
  source = "./ingress-router"

  host_name          = local.nodes.ingress_router_1.host_name
  host_type          = local.nodes.ingress_router_1.type
  domain             = local.domain
  zt_network_name    = "Ingress Overlay 1"
  zt_network_address = "10.30.9.0/24"
  zt_overlay_network = zerotier_network.overlay.id
  zt_start_ip        = "10.30.9.10"
  zt_end_ip          = "10.30.9.250"
  zt_overlay_ip      = local.nodes.ingress_router_1.zerotier_ip[0]
  zt_ingress_ip      = local.nodes.ingress_router_1.zerotier_ip[1]
}

module "ingress_router_secondary" {
  source = "./ingress-router"

  host_name          = local.nodes.ingress_router_2.host_name
  host_type          = local.nodes.ingress_router_2.type
  domain             = local.domain
  zt_network_name    = "Ingress Overlay 2"
  zt_network_address = "10.30.10.0/24"
  zt_overlay_network = zerotier_network.overlay.id
  zt_start_ip        = "10.30.10.10"
  zt_end_ip          = "10.30.10.250"
  zt_overlay_ip      = local.nodes.ingress_router_2.zerotier_ip[0]
  zt_ingress_ip      = local.nodes.ingress_router_2.zerotier_ip[1]
}