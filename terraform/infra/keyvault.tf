################################
# Key Vault
################################
resource "azurerm_key_vault" "app" {
  name                       = "${var.prefix}-${var.env}-vault"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
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

################################
# Key Vault secrets
################################
# Django app
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

resource "azurerm_key_vault_secret" "webappcontainer_client_id" {
  name         = "WEBAPPCONTAINER-CLIENT-ID"
  value        = azurerm_user_assigned_identity.webappcontainer.client_id
  key_vault_id = azurerm_key_vault.app.id
}

# Azure Cache for Redis
resource "azurerm_key_vault_secret" "redis_host" {
  name         = "REDIS-HOST"
  value        = azurerm_redis_cache.redis.hostname
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "redis_key" {
  name         = "REDIS-KEY"
  value        = azurerm_redis_cache.redis.primary_access_key
  key_vault_id = azurerm_key_vault.app.id
}

# Azure Database for MySQL Flexible Server
resource "azurerm_key_vault_secret" "db_host" {
  name         = "DB-HOST"
  value        = azurerm_mysql_flexible_server.mysql.fqdn
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "DB-NAME"
  value        = var.db_name
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "DB-USERNAME"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.app.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "DB-PASSWORD"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.app.id
}

# Application insights
resource "azurerm_key_vault_secret" "appinsights" {
  name         = "APPINSIGHTS-CONNECTION-STRING"
  value        = azurerm_application_insights.app.connection_string
  key_vault_id = azurerm_key_vault.app.id
}
