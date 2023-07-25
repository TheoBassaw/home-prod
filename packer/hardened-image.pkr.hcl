packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

source "oracle-oci" "ashburn" {
  availability_domain = "wkHw:US-ASHBURN-AD-1"
  base_image_ocid     = "ocid1.image.oc1.iad.aaaaaaaalwr5atko6n7ia2pz5q2s5soy6ad6paujwqslgeqmrgyy4hnqoilq"
  compartment_ocid    = var.tenancy
  image_name          = "Ubuntu-22.04-Hardened Image"
  shape               = "VM.Standard.A1.Flex"
  subnet_ocid         = "ocid1.subnet.oc1.iad.aaaaaaaaqt7w3xfuisgmamsmoerbfuwrmurnbt2krvabbezeka7ff6kl7xwq"

  region              = "us-ashburn-1"
  tenancy_ocid        = var.tenancy
  user_ocid           = "ocid1.user.oc1..aaaaaaaaja7xgz4fn4epc7ggz6ck7aqb6vjipfswtkeqa427w72zks64xfea"
  fingerprint         = "df:25:a5:50:84:e4:36:d3:53:56:4a:7e:a0:fa:73:dd"
  key_file            = "${path.root}/../secrets/oci_api_key.pem"
  ssh_username        = "ubuntu"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }
}

build {
  sources = ["source.oracle-oci.ashburn"]

  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/local.yml"
    galaxy_file   = "${path.root}/../ansible/requirements.yml"
    roles_path    = "${path.root}/../ansible/roles"
    use_proxy     = false
  }
}