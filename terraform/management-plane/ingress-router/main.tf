terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = ">= 1.4.2"
    }
    vultr = {
      source  = "vultr/vultr"
      version = ">= 2.19.0"
    }
  }
}