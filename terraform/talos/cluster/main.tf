terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "cluster/talos.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = { 
      s3 = "https://9f2db25dca87fbbfa880e006c9667d83.r2.cloudflarestorage.com/" 
    }
  }
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.8.1"
    }
  }
}

locals {
  cluster-name = "home-cluster"
  nodes = {
    talos-control-home-1 = {
      machine_type = "controlplane"
      apply_ip     = "10.20.0.201"
    }
    talos-control-home-2 = {
      machine_type = "controlplane"
      apply_ip     = "10.20.0.202"
    }
    talos-control-home-3 = {
      machine_type = "controlplane"
      apply_ip     = "10.20.0.203"
    }
  }
}

data "talos_machine_configuration" "machine_configuration" {
  for_each         = local.nodes
  cluster_name     = local.cluster-name
  machine_type     = each.value.machine_type
  cluster_endpoint = "https://10.20.0.200:6443"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version    = "1.11.2"
}

data "talos_client_configuration" "client_configuration" {
  cluster_name         = local.cluster-name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
}

resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_image_factory_schematic" "schematic" {
  schematic = file("${path.root}/schematic.yaml")
}

resource "talos_machine_configuration_apply" "this" {
  for_each                    = local.nodes
  client_configuration        = data.talos_client_configuration.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machine_configuration.machine_configuration
  node                        = each.value.apply_ip
}