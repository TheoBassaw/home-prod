data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "route_controller" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.shape
  display_name        = "Route Controller"
  freeform_tags       = {"type": "route_controller"}

  metadata = {
    user_data = data.cloudinit_config.route_controller.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "nginx" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  shape               = var.shape
  display_name        = "Nginx"
  freeform_tags       = {"type": "nginx"}

  metadata = {
    user_data = data.cloudinit_config.nginx.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "personal_devices" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = var.shape
  display_name        = "Personal Devices VPN"
  freeform_tags       = {"type": "personal_devices"}

  metadata = {
    user_data = data.cloudinit_config.personal_devices.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}

resource "oci_core_instance" "gitlab_runner" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  shape               = var.shape
  display_name        = "Gitlab Runner"
  freeform_tags       = {"type": "gitlab_runner"}

  metadata = {
    user_data = data.cloudinit_config.gitlab_runner.rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }
  
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  source_details {
    source_id   = var.image_ocid
    source_type = var.source_type
  }
}