data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "route_controller_1" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.shape
  display_name        = "Route Controller 1"
  freeform_tags       = {"type": "route_controller"}

  metadata = {
    user_data = data.cloudinit_config.route_controller_1.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "route_controller_2" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = var.shape
  display_name        = "Route Controller 2"
  freeform_tags       = {"type": "route_controller"}

  metadata = {
    user_data = data.cloudinit_config.route_controller_2.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "ingress_1" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.shape
  display_name        = "Ingress 1"
  freeform_tags       = {"type": "ingress"}

  metadata = {
    user_data = data.cloudinit_config.ingress_1.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "ingress_2" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = var.shape
  display_name        = "Ingress 2"
  freeform_tags       = {"type": "ingress"}

  metadata = {
    user_data = data.cloudinit_config.ingress_2.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}