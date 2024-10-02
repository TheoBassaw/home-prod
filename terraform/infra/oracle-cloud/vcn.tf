resource "oci_core_vcn" "vcn" {
  compartment_id          = var.compartment_id
  display_name            = "vcn"
  cidr_blocks             = ["10.0.0.0/23"]
  is_ipv6enabled          = true
  ipv6private_cidr_blocks = ["fc00::/63"]
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "internet-gateway"
  enabled        = true
}

resource "oci_core_route_table" "ig_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ig_route_table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.ig.id
    description       = "Default Route"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-subnet-sl"

  egress_security_rules {
    description      = "To Internet"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "Allow VCN"
    protocol    = "all"
    source      = "10.0.0.0/23"
    source_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "Allow VCN"
    protocol    = 6
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_security_list" "public_subnet_sl_dos" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-subnet-sl-dos"

  egress_security_rules {
    description      = "To Internet"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "Allow VCN"
    protocol    = "all"
    source      = "10.0.0.0/23"
    source_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  cidr_block        = "10.0.0.0/24"
  ipv6cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 0),
    "fc00::/64"
  ]
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "public-subnet"
  security_list_ids = [oci_core_security_list.public_subnet_sl.id]
  route_table_id    = oci_core_route_table.ig_route_table.id
}

resource "oci_core_subnet" "public_subnet_dos" {
  compartment_id    = var.compartment_id
  cidr_block        = "10.0.1.0/24"
  ipv6cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 1),
    "fc00:0000:0000:0001::/64"
  ]
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "public-subnet-dos"
  security_list_ids = [oci_core_security_list.public_subnet_sl_dos.id]
  route_table_id    = oci_core_route_table.ig_route_table.id
}