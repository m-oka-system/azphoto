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

module "network_security_group" {
  source = "../../modules/network_security_group"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  network_security_group = var.network_security_group
  subnet                 = module.network.subnet
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
  random              = local.common.random
  storage             = var.storage
  blob_container      = var.blob_container
}

module "key_vault" {
  source = "../../modules/key_vault"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  key_vault           = var.key_vault
  tenant_id           = local.common.tenant_id
}

module "app_key_vaul_secrets" {
  source = "../../modules/key_vault_secret"

  key_vault         = module.key_vault.key_vault
  key_vault_secrets = local.key_vault.key_vaul_secrets
  target_key_vault  = "app"
}

module "mysql" {
  source = "../../modules/mysql"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = local.common.random
  mysql               = var.mysql
  database            = var.database
  vnet                = module.network.vnet
  subnet              = module.network.subnet
}

module "redis" {
  source = "../../modules/redis"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = local.common.random
  redis               = var.redis
}

module "private_dns_zone" {
  source = "../../modules/private_dns_zone"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  private_dns_zone    = var.private_dns_zone
  vnet                = module.network.vnet
  target_vnet         = "spoke1"
}

module "private_endpoint" {
  source = "../../modules/private_endpoint"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  private_endpoint    = local.private_endpoint
  subnet              = module.network.subnet
  private_dns_zone    = module.private_dns_zone.private_dns_zone
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
  app_settings        = local.app_service.app_settings
  subnet              = module.network.subnet
  identity            = module.user_assigned_identity.user_assigned_identity
  frontdoor_profile   = module.frontdoor.frontdoor_profile
  dns                 = var.dns
  dns_zone            = module.dns.dns_zone
}

module "frontdoor" {
  source = "../../modules/frontdoor"

  common                         = var.common
  resource_group_name            = module.resource_group.resource_group_name
  frontdoor_profile              = var.frontdoor_profile
  frontdoor_endpoint             = var.frontdoor_endpoint
  frontdoor_origin_group         = var.frontdoor_origin_group
  frontdoor_origin               = var.frontdoor_origin
  frontdoor_route                = var.frontdoor_route
  frontdoor_security_policy      = var.frontdoor_security_policy
  frontdoor_firewall_policy      = var.frontdoor_firewall_policy
  frontdoor_firewall_custom_rule = var.frontdoor_firewall_custom_rule
  backend_origins                = local.front_door.backend_origins
  dns                            = var.dns
  dns_zone                       = module.dns.dns_zone
}

module "user_assigned_identity" {
  source = "../../modules/user_assigned_identity"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  subscription_id        = local.common.subscription_id
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

module "diagnostic_setting" {
  source = "../../modules/diagnostic_setting"

  common                  = var.common
  diagnostic_setting      = local.diagnostic_setting
  log_analytics_workspace = module.log_analytics.log_analytics
}
