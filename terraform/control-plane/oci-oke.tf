data "oci_containerengine_cluster_kube_config" "control_cluster_kube_config" {
  cluster_id = oci_containerengine_cluster.control_cluster.id
}

resource "oci_containerengine_cluster" "control_cluster" {
  compartment_id     = var.tenancy_ocid
  kubernetes_version = "v1.26.2"
  name               = "Control Cluster"
  vcn_id             = oci_core_vcn.control.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.control_public.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.control_public.id]
  }
}

resource "oci_containerengine_node_pool" "arm_node_pool" {
  compartment_id = var.tenancy_ocid
  cluster_id     = oci_containerengine_cluster.control_cluster.id
  name           = "Arm Pool"
  node_shape     = "VM.Standard.A1.Flex"

  node_config_details {
    is_pv_encryption_in_transit_enabled = true
    size                                = 4
    
    placement_configs {
      availability_domain = "wkHw:US-ASHBURN-AD-1"
      subnet_id           = oci_core_subnet.control_private.id
    }

    placement_configs {
      availability_domain = "wkHw:US-ASHBURN-AD-2"
      subnet_id           = oci_core_subnet.control_private.id
    }

    placement_configs {
      availability_domain = "wkHw:US-ASHBURN-AD-3"
      subnet_id           = oci_core_subnet.control_private.id
    }
  }

  node_shape_config {
    memory_in_gbs = 6
    ocpus         = 2
  }

  node_source_details {
    source_type = "image"
    image_id    = "ocid1.image.oc1.iad.aaaaaaaadplni6z4njatenqrmdqnnve2zqelex75tvn4sxgoveaynz4kqjxq"
  }
}

resource "local_file" "kubeconfig" {
  content    = data.oci_containerengine_cluster_kube_config.control_cluster_kube_config.content
  filename   = "${path.module}/secrets/config.yaml"
  depends_on = [oci_containerengine_node_pool.arm_node_pool]
}