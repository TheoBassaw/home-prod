resource "zerotier_identity" "k8s_hosts" {
  for_each = { for k,v in var.hosts: k => v if v.type == "k8s_server"}
}

resource "zerotier_member" "k8s_hosts" {
  for_each = { for k,v in var.hosts: k => v if v.type == "k8s_server"}

  name           = each.value.host_name
  member_id      = zerotier_identity.k8s_hosts[each.key].id
  network_id     = var.zt_overlay_id
}

data "cloudinit_config" "k8s_hosts" {
  for_each = { for k,v in var.hosts: k => v if v.type == "k8s_server"}

  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.root}/templates/userdata-k8s.tftpl", {
      "host_name"         = each.value.host_name
      "domain"            = var.domain
      "zt_public"         = zerotier_identity.k8s_hosts[each.key].public_key
      "zt_private"        = zerotier_identity.k8s_hosts[each.key].private_key
      "zt_overlay"        = var.zt_overlay_id
    })
  }
}

resource "oci_core_instance" "k8s_hosts" {
  for_each = { for k,v in var.hosts: k => v if v.type == "k8s_server"}

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.availability_domain].name
  shape               = var.shape
  display_name        = each.value.host_name
  freeform_tags       = {
    "type": each.value.type
  }

  metadata = {
    user_data = data.cloudinit_config.k8s_hosts[each.key].rendered
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.control_public.id
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  source_details {
    source_id               = var.image_ocid
    source_type             = var.source_type
    boot_volume_size_in_gbs = 100
  }
}