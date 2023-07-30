terraform {
  required_version = "~> 1.5.0"
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

module "mysql" {
  source = "../../modules/mysql"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = random_integer.num.result
  mysql               = var.mysql
  database            = var.database
  vnet                = module.network.vnet
  subnet              = module.network.subnet
}

module "vm" {
  source = "../../modules/vm"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  vm                  = var.vm
  subnet              = module.network.subnet
}

module "container_registry" {
  source = "../../modules/container_registry"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  container_registry  = var.container_registry
}

module "app_service" {
  source = "../../modules/app_service"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  app_service         = var.app_service
  subnet              = module.network.subnet
}

module "frontdoor" {
  source = "../../modules/frontdoor"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  frontdoor              = var.frontdoor
  frontdoor_endpoint     = var.frontdoor_endpoint
  frontdoor_origin_group = var.frontdoor_origin_group
  frontdoor_origin       = var.frontdoor_origin
  frontdoor_route        = var.frontdoor_route
  app_service            = module.app_service.app_service
}
