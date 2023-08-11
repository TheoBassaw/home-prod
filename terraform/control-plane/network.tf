data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_vcn" "control" {
  compartment_id = var.tenancy_ocid
  display_name   = "Control Network"
  dns_label      = "paradise"
  cidr_blocks    = ["10.30.16.0/23"]
  is_ipv6enabled = true
}

resource "oci_core_internet_gateway" "control_internet_gateway" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Internet Gateway"
  enabled        = true
}

resource "oci_core_nat_gateway" "control_nat_gateway" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Nat Gateway"
}

resource "oci_core_service_gateway" "control_service_gateway" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Service Gateway"

  services {
    service_id = lookup(data.oci_core_services.all_oci_services.services[0], "id")
  }
}

resource "oci_core_route_table" "public_routes" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Control Route Table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.control_internet_gateway.id
    description       = "Default route"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "private_routes" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Control Route Table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.control_nat_gateway.id
    description       = "Default route"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_service_gateway.control_service_gateway.id
    description       = "Service Gateway Route"
    destination       = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "control_public" {
  compartment_id    = var.tenancy_ocid
  cidr_block        = "10.30.16.0/24"
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.control.ipv6cidr_blocks[0], 8, 0)
  vcn_id            = oci_core_vcn.control.id
  display_name      = "Control Public"
  route_table_id    = oci_core_route_table.public_routes.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

resource "oci_core_subnet" "control_private" {
  compartment_id = var.tenancy_ocid
  cidr_block        = "10.30.17.0/24"
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.control.ipv6cidr_blocks[0], 8, 1)
  vcn_id            = oci_core_vcn.control.id
  display_name      = "Control Private"
  route_table_id    = oci_core_route_table.private_routes.id
  security_list_ids = [oci_core_security_list.private_sl.id]
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Public Security List"

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
    description = "k8s-api"
    protocol    = 6
    source      = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

   ingress_security_rules {
    description = "Worker to k8s-api"
    protocol    = 6
    source      = "10.30.17.0/24"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    description = "http"
    protocol    = 6
    source      = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "https"
    protocol    = 6
    source      = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_security_list" "private_sl" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Private Security List"

  egress_security_rules {
    description      = "To Internet"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    description = "Pod to Pod"
    protocol    = "all"
    source      = "10.30.17.0/24"
  }

  ingress_security_rules {
    description = "k8s-api communication"
    protocol    = 6
    source      = "10.30.16.0/24"
  }

  ingress_security_rules {
    description = "icmp"
    protocol    = 1
    source      = "0.0.0.0/0"
  }
}