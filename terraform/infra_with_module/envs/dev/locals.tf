locals {
  common = {
    subscription_id = data.azurerm_subscription.primary.subscription_id
    tenant_id       = data.azurerm_subscription.primary.tenant_id
    random          = random_integer.num.result
  }

  django_app = {
    service_fqdn = "${var.dns.custom_domain_host_name}.${var.dns.dns_zone_name}"
  }

  key_vault = {
    key_vaul_secrets = {
      django_secret_key             = var.django_app.secret_key
      sendgrid_api_key              = var.django_app.sendgrid_api_key
      default_from_email            = var.django_app.default_from_email
      webappcontainer_client_id     = module.user_assigned_identity.user_assigned_identity["app"].client_id
      redis_host                    = module.redis.redis["app"].hostname
      redis_key                     = module.redis.redis["app"].primary_access_key
      redis_port                    = var.redis["app"].redis_port
      db_host                       = module.mysql.mysql["app"].fqdn
      db_name                       = var.database["app"].name
      db_username                   = var.mysql["app"].db_username
      db_password                   = var.mysql["app"].db_password
      db_port                       = var.mysql["app"].db_port
      appinsights_connection_string = module.application_insights.application_insights["app"].connection_string
    }
  }

  private_endpoint = {
    blob = {
      name                           = module.storage.storage_account["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "blob"
      subresource_names              = ["blob"]
      private_connection_resource_id = module.storage.storage_account["app"].id
    }
    key_vault = {
      name                           = module.key_vault.key_vault["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "key_vault"
      subresource_names              = ["vault"]
      private_connection_resource_id = module.key_vault.key_vault["app"].id
    }
    redis = {
      name                           = module.redis.redis["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "redis"
      subresource_names              = ["redisCache"]
      private_connection_resource_id = module.redis.redis["app"].id
    }
  }

  app_service = {
    app_settings = {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = var.django_app.websites_enable_app_service_storage
      "WEBSITES_PORT"                       = var.django_app.websites_port
      "DJANGO_SETTINGS_MODULE"              = var.django_app.django_settings_module
      "DJANGO_SECURE_SSL_REDIRECT"          = var.django_app.django_secure_ssl_redirect
      "DJANGO_DEBUG"                        = var.django_app.django_debug
      "DJANGO_ALLOWED_HOSTS"                = local.django_app.service_fqdn
      "DJANGO_AZURE_ACCOUNT_NAME"           = module.storage.storage_account["app"].name
      "DJANGO_AZURE_STATIC_CONTAINER"       = module.storage.storage_container["app_static"].name
      "DJANGO_AZURE_MEDIA_CONTAINER"        = module.storage.storage_container["app_media"].name
      "DB_HOST"                             = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DB-HOST)"
      "DB_NAME"                             = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DB-NAME)"
      "DB_USERNAME"                         = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DB-USERNAME)"
      "DB_PASSWORD"                         = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DB-PASSWORD)"
      "DB_PORT"                             = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DB-PORT)"
      "REDIS_HOST"                          = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=REDIS-HOST)"
      "REDIS_KEY"                           = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=REDIS-KEY)"
      "REDIS_PORT"                          = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=REDIS-PORT)"
      "SENDGRID_API_KEY"                    = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=SENDGRID-API-KEY)"
      "DJANGO_DEFAULT_FROM_EMAIL"           = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DEFAULT-FROM-EMAIL)"
      "DJANGO_SECRET_KEY"                   = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DJANGO-SECRET-KEY)"
      "APPINSIGHTS_CONNECTION_STRING"       = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=APPINSIGHTS-CONNECTION-STRING)"
      "AZURE_CLIENT_ID"                     = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=WEBAPPCONTAINER-CLIENT-ID)"
    }
  }

  front_door = {
    backend_origins = {
      app = {
        host_name          = module.app_service.app_service["app"].default_hostname
        origin_host_header = module.app_service.app_service["app"].default_hostname
      }
      blob = {
        host_name          = module.storage.storage_account["app"].primary_blob_host
        origin_host_header = module.storage.storage_account["app"].primary_blob_host
      }
    }
  }
}
