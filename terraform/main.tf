terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.33.0"
    }
  }
  cloud {
    organization = "m-oka-system"

    workspaces {
      name = "azphoto"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "random_integer" "num" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.env}-rg"
  location = var.location
}

module "blob_pep" {
  source = "./modules/private_endpoint"

  prefix                         = var.prefix
  env                            = var.env
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  resource_name                  = azurerm_storage_account.app.name
  private_connection_resource_id = azurerm_storage_account.app.id
  virtual_network_id             = azurerm_virtual_network.spoke1.id
  subnet_id                      = azurerm_subnet.spoke1_endpoint.id
  subresource_names              = ["blob"]
  private_dns_host_name          = azurerm_storage_account.app.name
  private_dns_zone_name          = "privatelink.blob.core.windows.net"
}

module "vault_pep" {
  source = "./modules/private_endpoint"

  prefix                         = var.prefix
  env                            = var.env
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  resource_name                  = azurerm_key_vault.app.name
  private_connection_resource_id = azurerm_key_vault.app.id
  virtual_network_id             = azurerm_virtual_network.spoke1.id
  subnet_id                      = azurerm_subnet.spoke1_endpoint.id
  subresource_names              = ["vault"]
  private_dns_host_name          = azurerm_key_vault.app.name
  private_dns_zone_name          = "privatelink.vaultcore.azure.net"
}
