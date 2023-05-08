################################
# Azure Container Registry
################################
locals {
  container_registry_name = "${var.prefix}${var.env}acr"
}

resource "azurerm_container_registry" "acr" {
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.container_registry_sku_name
  admin_enabled       = false
}

################################
# Web App for Containers
################################
resource "azurerm_service_plan" "app" {
  name                = "${var.prefix}-${var.env}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.web_app_sku_name
}

resource "azurerm_linux_web_app" "app" {
  name                      = "${var.prefix}-${var.env}-app-${random_integer.num.result}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  service_plan_id           = azurerm_service_plan.app.id
  virtual_network_subnet_id = azurerm_subnet.spoke1_app.id
  https_only                = true

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${local.container_registry_name}.azurecr.io"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "False"
    "WEBSITES_PORT"                       = "8000"
    "DJANGO_SETTINGS_MODULE"              = "config.settings.production"
    "DJANGO_SECURE_SSL_REDIRECT"          = "False"
    "DJANGO_DEBUG"                        = "False"
    "DJANGO_ALLOWED_HOSTS"                = local.service_fqdn
    "DJANGO_AZURE_ACCOUNT_NAME"           = azurerm_storage_account.app.name
    "DJANGO_AZURE_STATIC_CONTAINER"       = azurerm_storage_container.static.name
    "DJANGO_AZURE_MEDIA_CONTAINER"        = azurerm_storage_container.media.name
    "DB_HOST"                             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DB-HOST)"
    "DB_NAME"                             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DB-NAME)"
    "DB_USERNAME"                         = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DB-USERNAME)"
    "DB_PASSWORD"                         = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DB-PASSWORD)"
    "DB_PORT"                             = "3306"
    "REDIS_HOST"                          = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=REDIS-HOST)"
    "REDIS_KEY"                           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=REDIS-KEY)"
    "REDIS_PORT"                          = "6380"
    "SENDGRID_API_KEY"                    = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=SENDGRID-API-KEY)"
    "DJANGO_DEFAULT_FROM_EMAIL"           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DEFAULT-FROM-EMAIL)"
    "DJANGO_SECRET_KEY"                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=DJANGO-SECRET-KEY)"
    "AZURE_CLIENT_ID"                     = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=AZURE-CLIENT-ID)"
    "AZURE_TENANT_ID"                     = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=AZURE-TENANT-ID)"
    "AZURE_CLIENT_SECRET"                 = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.app.name};SecretName=AZURE-CLIENT-SECRET)"
  }

  # Use Key Vault references for App Service
  # https://learn.microsoft.com/ja-jp/azure/app-service/app-service-key-vault-references
  key_vault_reference_identity_id = azurerm_user_assigned_identity.webappcontainer.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.webappcontainer.id
    ]
  }

  site_config {
    always_on              = false
    ftps_state             = "Disabled"
    vnet_route_all_enabled = true

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.webappcontainer.client_id
  }

  lifecycle {
    ignore_changes = [site_config[0].application_stack[0].docker_image_tag]
  }
}

################################
# Log Analytics workspace
################################
resource "azurerm_log_analytics_workspace" "app" {
  name                = "${azurerm_linux_web_app.app.name}-logs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

locals {
  log_categories = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "${azurerm_linux_web_app.app.name}-diag-setting"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app.id

  dynamic "log" {
    for_each = local.log_categories

    content {
      category = log.value
      enabled  = true

      retention_policy {
        days    = 30
        enabled = true
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 30
      enabled = true
    }
  }
}
