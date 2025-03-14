resource "flux_bootstrap_git" "bootstrap" {
  path = "kubernetes/clusters/bootstrap-cluster"
}

/*
resource "kubernetes_manifest" "talos_linux_namespace" {
  manifest = yamldecode(file("${path.root}/../../../kubernetes/clusters/bootstrap-cluster/apps/talos-linux/namespace.yaml"))
}

resource "kubernetes_manifest" "talos_linux_pvc" {
  manifest = yamldecode(file("${path.root}/../../../kubernetes/clusters/bootstrap-cluster/apps/talos-linux/pvc.yaml"))
  depends_on = [kubernetes_manifest.talos_linux_namespace]
}

resource "kubernetes_manifest" "talos_linux_deployment" {
  manifest = yamldecode(file("${path.root}/../../../kubernetes/clusters/bootstrap-cluster/apps/talos-linux/deployment.yaml"))
  depends_on = [kubernetes_manifest.talos_linux_namespace]
}*/