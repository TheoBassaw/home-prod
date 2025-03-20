data "kubectl_path_documents" "talos_linux" {
  pattern = "${path.root}/../../../kubernetes/clusters/bootstrap-cluster/apps/talos-linux/*.yaml"
}

data "talos_machine_configuration" "this" {
  cluster_name     = "example-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://cluster.local:6443"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = "example-cluster"
  client_configuration = talos_machine_secrets.secrets.client_configuration
  nodes                = ["10.5.0.2"]
}

resource "kubectl_manifest" "talos_linux" {
  for_each   = data.kubectl_path_documents.talos_linux.manifests
  yaml_body  = each.value
  apply_only = true
}

resource "talos_machine_secrets" "secrets" {}