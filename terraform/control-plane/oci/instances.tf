data "cloudinit_config" "route_reflector" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "route-reflector-1" : "route-reflector-2"
      "domain"     = "paradisenetworkz.com"
      "zt_public"  = zerotier_identity.route_reflector.public_key
      "zt_private" = zerotier_identity.route_reflector.private_key
      "zt_network" = var.zerotier_network
    })
  }
}

data "cloudinit_config" "private_dns" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname"   = var.profile == "PRIMARY" ? "dns-server-1" : "dns-server-2"
      "domain"     = "paradisenetworkz.com"
      "zt_public"  = zerotier_identity.dns_server.public_key
      "zt_private" = zerotier_identity.dns_server.private_key
      "zt_network" = var.zerotier_network
    })
  }
}

resource "oci_core_instance" "route_reflector" {
  compartment_id      = var.compartment_id
  availability_domain = var.profile == "PRIMARY" ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "Route Reflector"
  freeform_tags       = {"type": "route_reflector"}

  metadata = {
    user_data = data.cloudinit_config.route_reflector.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaaevjttsicdlm4h3zomclg6pztgxgg7ba54e27c4oopvkbaftvjqna"
    source_type = "image"
  }
}

resource "oci_core_instance" "private_dns" {
  compartment_id      = var.compartment_id
  availability_domain = var.profile == "PRIMARY" ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "Private DNS"
  freeform_tags       = {"type": "dns_server"}

  metadata = {
    user_data = data.cloudinit_config.private_dns.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaaevjttsicdlm4h3zomclg6pztgxgg7ba54e27c4oopvkbaftvjqna"
    source_type = "image"
  }
}