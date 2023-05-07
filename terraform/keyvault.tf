################################
# Key Vault
################################
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "app" {
  name                       = "${var.prefix}-${var.env}-vault"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  access_policy              = []

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.allowed_cidr
  }
}

# Secret
resource "azurerm_key_vault_secret" "secret_key" {
  name         = "DJANGO-SECRET-KEY"
  value        = var.secret_key
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "sendgrid_api_key" {
  name         = "SENDGRID-API-KEY"
  value        = var.sendgrid_api_key
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "default_from_email" {
  name         = "DEFAULT-FROM-EMAIL"
  value        = var.default_from_email
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "azure_client_id" {
  name         = "AZURE-CLIENT-ID"
  value        = var.azure_client_id
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "azure_tenant_id" {
  name         = "AZURE-TENANT-ID"
  value        = var.azure_tenant_id
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "azure_client_secret" {
  name         = "AZURE-CLIENT-SECRET"
  value        = var.azure_client_secret
  key_vault_id = azurerm_key_vault.app.id
}
