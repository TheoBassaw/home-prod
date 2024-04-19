data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  shape                    = "VM.Standard.A1.Flex"
  operating_system_version = "22.04"
  operating_system         = "Canonical Ubuntu"
  sort_order               = "DESC"
}