data "cloudinit_config" "route_reflector" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/userdata.tftpl", {
      "hostname" = var.profile == "PRIMARY" ? "route_reflector_1" : "route_reflector_2"
      "domain"   = "paradisenetworkz.com"
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
      "hostname" = var.profile == "PRIMARY" ? "dns_server_1" : "dns_server_2"
      "domain"   = "paradisenetworkz.com"
    })
  }
}

resource "oci_core_instance" "route_reflector" {
  compartment_id      = var.compartment_id
  availability_domain = var.profile == "PRIMARY" ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "Route Reflector"

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