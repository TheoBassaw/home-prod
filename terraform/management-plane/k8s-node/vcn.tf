resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_id
  display_name   = "Main VCN"
  cidr_blocks    = [var.vcn_cidr_block]
  is_ipv6enabled = true
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Internet Gateway"
  enabled        = true
}

resource "oci_core_route_table" "internet_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Internet Gateway Route Table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
    description       = "Default route"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "main_subnet" {
  compartment_id    = var.compartment_id
  cidr_block        = var.vcn_cidr_block
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.main_vcn.ipv6cidr_blocks[0], 8, 0)
  vcn_id            = oci_core_vcn.main_vcn.id
  display_name      = "Main Subnet"
  route_table_id    = oci_core_route_table.internet_route_table.id
  security_list_ids = [oci_core_security_list.main_subnet_sl.id]
}

resource "oci_core_security_list" "main_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "Main Subnet Security List"

  egress_security_rules {
    description      = "To Internet"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "icmp"
    protocol    = 1
    source      = "0.0.0.0/0"
  }

  ingress_security_rules {
    description = "zerotier"
    protocol    = 6
    source      = "0.0.0.0/0"
    tcp_options {
      min = 9993
      max = 9993
    }
  }

  ingress_security_rules {
    description = "SSH"
    protocol    = 6
    source      = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}