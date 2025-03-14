data "kubectl_path_documents" "talos_linux" {
    pattern = "${path.root}/../../../kubernetes/clusters/bootstrap-cluster/apps/talos-linux/*.yaml"
}

resource "flux_bootstrap_git" "bootstrap" {
  path = "kubernetes/clusters/bootstrap-cluster"
}

resource "kubectl_manifest" "talos_linux" {
  for_each  = data.kubectl_path_documents.talos_linux.manifests
  yaml_body = each.value
}