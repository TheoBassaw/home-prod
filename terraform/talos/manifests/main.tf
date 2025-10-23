terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "talos/manifests.tfstate"
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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "admin@home-cluster"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "admin@home-cluster"
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.18.2"
  namespace  = "kube-system"
  values     = [file("${path.root}/../../../kubernetes/cluster-apps/kube-system/cilium/helm-values.yaml")]
  atomic     = true

  lifecycle {
    ignore_changes = [version]
  }
}

resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts/"
  chart            = "flux-operator"
  version          = "0.30.0"
  namespace        = "flux-system"
  create_namespace = true
  depends_on       = [helm_release.cilium]

}

resource "kubernetes_manifest" "flux_instance" {
  manifest   = yamldecode(file("${path.root}/../../../kubernetes/cluster-apps/flux-system/flux-instance.yaml"))
  depends_on = [helm_release.flux_operator]
}