terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "talos/cluster.tfstate"
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
  cluster-name  = "home-cluster"
  talos-version = "1.11.2"
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
  talos_version    = local.talos-version
  config_patches   = [
    file("${path.root}/all.yaml"),
    file("${path.root}/${each.key}.yaml"),
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.schematic.id}:v${local.talos-version}"
        }
      }
    })
  ]
}

data "talos_client_configuration" "client_configuration" {
  cluster_name         = local.cluster-name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  nodes                = [for node in local.nodes: "${node.apply_ip}"]
  endpoints            = [for node in local.nodes: "${node.apply_ip}"]
}

resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_image_factory_schematic" "schematic" {
  schematic = file("${path.root}/schematic.yaml")
}

resource "talos_machine_configuration_apply" "configuration_apply" {
  for_each                    = local.nodes
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machine_configuration[each.key].machine_configuration
  node                        = each.value.apply_ip
}

resource "talos_machine_bootstrap" "bootstrap" {
  node                 = element([for node in local.nodes: "${node.apply_ip}"], 0)
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  depends_on           = [talos_machine_configuration_apply.configuration_apply]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration         = talos_machine_secrets.machine_secrets.client_configuration
  node                         = element([for node in local.nodes: "${node.apply_ip}"], 0)
  depends_on                   = [talos_machine_bootstrap.bootstrap]
}

resource "local_sensitive_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = pathexpand("~/.kube/config")
}

resource "local_sensitive_file" "talosconfig" {
  content  = data.talos_client_configuration.client_configuration.talos_config
  filename = pathexpand("~/.talos/config")
}