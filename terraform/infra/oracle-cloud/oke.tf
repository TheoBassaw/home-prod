resource "oci_containerengine_cluster" "control_plane_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.30.1"
  name               = "Control Plane Cluster"
  vcn_id             = oci_core_vcn.vcn.id
  type               = "BASIC_CLUSTER"

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public_subnet.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public_subnet.id]
  }
}

resource "oci_containerengine_node_pool" "node_pool" {
  compartment_id     = var.compartment_id
  name               = "Node Pool"
  cluster_id         = oci_containerengine_cluster.control_plane_cluster.id
  node_shape         = "VM.Standard.A1.Flex"
  kubernetes_version = "v1.30.1"

  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  node_source_details {
    image_id                = "ocid1.image.oc1.iad.aaaaaaaa35afxc4q57i6xnd275vmtr57zjrccp3lyr26mwl4yfpx4lpb2koq"
    source_type             = "image"
    boot_volume_size_in_gbs = 100
  }

  node_config_details {
    size                                = 2
    is_pv_encryption_in_transit_enabled = true

    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.public_subnet_dos.id
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
      subnet_id           = oci_core_subnet.public_subnet_dos.id
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
      subnet_id           = oci_core_subnet.public_subnet_dos.id
    }
  }
}