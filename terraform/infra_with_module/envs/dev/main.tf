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

data "azurerm_subscription" "primary" {}

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
  random              = local.random
  storage             = var.storage
  blob_container      = var.blob_container
}

module "keyvault" {
  source = "../../modules/keyvault"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  keyvault            = var.keyvault
  tenant_id           = local.tenant_id
}

module "mysql" {
  source = "../../modules/mysql"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = local.random
  mysql               = var.mysql
  database            = var.database
  vnet                = module.network.vnet
  subnet              = module.network.subnet
}

module "redis" {
  source = "../../modules/redis"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = local.random
  redis               = var.redis
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
  service_plan        = var.service_plan
  app_service         = var.app_service
  subnet              = module.network.subnet
}

module "frontdoor" {
  source = "../../modules/frontdoor"

  common                         = var.common
  resource_group_name            = module.resource_group.resource_group_name
  frontdoor                      = var.frontdoor
  frontdoor_endpoint             = var.frontdoor_endpoint
  frontdoor_origin_group         = var.frontdoor_origin_group
  frontdoor_origin               = var.frontdoor_origin
  frontdoor_route                = var.frontdoor_route
  frontdoor_security_policy      = var.frontdoor_security_policy
  frontdoor_firewall_policy      = var.frontdoor_firewall_policy
  frontdoor_firewall_custom_rule = var.frontdoor_firewall_custom_rule
  backend_origins                = local.backend_origins
}

module "user_assigned_identity" {
  source = "../../modules/user_assigned_identity"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  subscription_id        = local.subscription_id
  user_assigned_identity = var.user_assigned_identity
  role_assignment        = var.role_assignment
}

module "log_analytics" {
  source = "../../modules/log_analytics"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  log_analytics       = var.log_analytics
}

module "application_insights" {
  source = "../../modules/application_insights"

  common               = var.common
  resource_group_name  = module.resource_group.resource_group_name
  application_insights = var.application_insights
  log_analytics        = module.log_analytics.log_analytics
}
