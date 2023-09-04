data "kubectl_file_documents" "vnf_namespace" {
  content = file("${path.module}/manifests/vnf-namespace.yaml")
}

resource "kubectl_manifest" "vnf_namespace" {
  for_each  = data.kubectl_file_documents.vnf_namespace.manifests
  yaml_body = each.value
}