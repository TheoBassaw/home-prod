data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci.compartment_id
}

resource "oci_core_vcn" "control" {
  compartment_id = var.oci.compartment_id
  display_name   = "Control Network"
  cidr_blocks    = [var.oci.oci_default_network]
  is_ipv6enabled = true
}

resource "oci_core_internet_gateway" "control_internet_gateway" {
  compartment_id = var.oci.compartment_id
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Internet Gateway"
  enabled        = true
}

resource "oci_core_route_table" "public_routes" {
  compartment_id = var.oci.compartment_id
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Control Route Table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.control_internet_gateway.id
    description       = "Default route"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "control_public" {
  compartment_id    = var.oci.compartment_id
  cidr_block        = var.oci.oci_default_network
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.control.ipv6cidr_blocks[0], 8, 0)
  vcn_id            = oci_core_vcn.control.id
  display_name      = "Control Public"
  route_table_id    = oci_core_route_table.public_routes.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.oci.compartment_id
  vcn_id         = oci_core_vcn.control.id
  display_name   = "Public Security List"

  egress_security_rules {
    description      = "To Internet"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = var.oci.oci_default_network
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

resource "oci_network_load_balancer_network_load_balancer" "ingress_nlb" {
  compartment_id                 = var.oci.compartment_id
  display_name                   = "Ingress NLB"
  subnet_id                      = oci_core_subnet.control_public.id
  is_private                     = false
  is_preserve_source_destination = false
}

resource "oci_network_load_balancer_backend_set" "bastion_backend_set" {
  name                     = "Bastion Backend Set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.ingress_nlb.id
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol = "TCP"
  }
}

resource "oci_network_load_balancer_listener" "bastion_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.bastion_backend_set.name
  name                     = "Bastion_Listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.ingress_nlb.id
  port                     = 22
  protocol                 = "TCP_AND_UDP"
}