terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.65.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_integer" "num" {
  min = 10000
  max = 99999
}


module "resource_group" {
  source = "../../modules/resource_group"

  common = var.common
}

module "network" {
  source = "../../modules/network"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  network             = var.network
  subnet              = var.subnet
}

module "dns" {
  source = "../../modules/dns"

  resource_group_name = module.resource_group.resource_group_name
  dns                 = var.dns
}

module "storage" {
  source = "../../modules/storage"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = random_integer.num.result
  storage             = var.storage
  blob_container      = var.blob_container
}

module "keyvault" {
  source = "../../modules/keyvault"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  keyvault            = var.keyvault
}
