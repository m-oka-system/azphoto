################################
# Storage Account
################################
resource "azurerm_storage_account" "app" {
  name                     = "${var.prefix}${var.env}acc${random_integer.num.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = var.account_replication_type

  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_storage_container" "static" {
  name                  = "static"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "blob"
}

resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "blob"
}
