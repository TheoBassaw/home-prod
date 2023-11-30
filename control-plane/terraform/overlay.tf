locals {
  asn       = "212364"
  aggregate = "10.30.0.0/16"
  overlay = {
    name    = "Overlay", 
    network = "10.30.0.0/24"
  }
  ingress = { 
    name    = "Ingress", 
    network = "10.30.1.0/24",
    vip     = "10.30.1.1"
  }
}

resource "zerotier_network" "overlay" {
  name = local.overlay.name

  route {
    target = local.overlay.network
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_network" "ingress" {
  name = local.ingress.name

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = cidrhost(local.ingress.network, 10)
    end   = cidrhost(local.ingress.network, 250)
  }

  route {
    target = local.ingress.network
  }

  route {
    target = local.aggregate
    via    = local.ingress.vip
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "doppler_secret" "overlay" {
  project = "k8s-home"
  config  = "prd"
  name    = "TF_VAR_ZT_OVERLAY"
  value   = zerotier_network.overlay.id
}