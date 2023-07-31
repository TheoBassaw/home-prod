packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

source "oracle-oci" "ashburn" {
  availability_domain = var.availability_domain
  base_image_ocid     = var.base_image_ocid
  compartment_ocid    = var.tenancy
  image_name          = var.image_name
  shape               = var.shape
  subnet_ocid         = var.subnet_ocid

  region              = var.region
  tenancy_ocid        = var.tenancy
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  key_file            = "${path.root}/../oci_api_key.pem"
  ssh_username        = var.ssh_username

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }
}

build {
  sources = ["source.oracle-oci.ashburn"]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/packer-image.yml"
    galaxy_file   = "${path.root}/ansible/requirements.yml"
    roles_path    = "${path.root}/ansible/roles"
    use_proxy     = false
  }
}