locals {
  common = {
    subscription_id   = data.azurerm_subscription.primary.subscription_id
    tenant_id         = data.azurerm_subscription.primary.tenant_id
    random            = random_integer.num.result
    client_ip_address = chomp(data.http.ipify.response_body)
  }

  key_vault = {
    key_vaul_secrets = {
      django_secret_key             = var.secret_key
      sendgrid_api_key              = var.sendgrid_api_key
      default_from_email            = var.default_from_email
      webappcontainer_client_id     = module.user_assigned_identity.user_assigned_identity["app"].client_id
      redis_host                    = module.redis.redis["app"].hostname
      redis_key                     = module.redis.redis["app"].primary_access_key
      redis_port                    = var.redis["app"].redis_port
      db_host                       = module.mysql.mysql["app"].fqdn
      db_name                       = var.database["app"].name
      db_username                   = var.db_username
      db_password                   = var.db_password
      db_port                       = var.mysql["app"].db_port
      appinsights_connection_string = module.application_insights.application_insights["app"].connection_string
    }
  }

  private_endpoint = {
    blob = {
      name                           = module.storage.storage_account["app"].name
      subnet_id                      = module.network.subnet["pe"].id
      private_dns_zone_ids           = [module.private_dns_zone.private_dns_zone["blob"].id]
      subresource_names              = ["blob"]
      private_connection_resource_id = module.storage.storage_account["app"].id
    }
    key_vault = {
      name                           = module.key_vault.key_vault["app"].name
      subnet_id                      = module.network.subnet["pe"].id
      private_dns_zone_ids           = [module.private_dns_zone.private_dns_zone["key_vault"].id]
      subresource_names              = ["vault"]
      private_connection_resource_id = module.key_vault.key_vault["app"].id
    }
    redis = {
      name                           = module.redis.redis["app"].name
      subnet_id                      = module.network.subnet["pe"].id
      private_dns_zone_ids           = [module.private_dns_zone.private_dns_zone["redis"].id]
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
      "DJANGO_ALLOWED_HOSTS"                = "${var.dns["app"].subdomain}.${var.dns["app"].dns_zone_name}"
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
        origin_host_header = "${var.dns["app"].subdomain}.${var.dns["app"].dns_zone_name}"
      }
      blob = {
        host_name          = module.storage.storage_account["app"].primary_blob_host
        origin_host_header = module.storage.storage_account["app"].primary_blob_host
      }
    }
  }

  diagnostic_setting = {
    target_log_analytics_workspace = "logs"
    target_storage_account         = "log"
    target_resources = merge(
      { for k, v in module.storage.storage_account : format("storage_account_%s", k) => v.id },
      { for k, v in module.storage.storage_account : format("blob_%s", k) => format("%s/blobServices/default", v.id) },
      { for k, v in module.key_vault.key_vault : format("key_vault_%s", k) => v.id },
      { for k, v in module.mysql.mysql : format("mysql_%s", k) => v.id },
      { for k, v in module.redis.redis : format("redis_%s", k) => v.id },
      { for k, v in module.container_registry.container_registry : format("container_registry_%s", k) => v.id },
      { for k, v in module.app_service.app_service : format("app_service_%s", k) => v.id },
      { for k, v in module.frontdoor.frontdoor_profile : format("frontdoor_%s", k) => v.id },
    )
  }

  # Alert rule
  metric_alert = {
    plan_cpu_average = {
      name        = module.app_service.app_service_plan["app"].name
      scope_id    = module.app_service.app_service_plan["app"].id
      severity    = 3
      frequency   = "PT1M"
      window_size = "PT5M"
      criteria = {
        metric_namespace = "Microsoft.Web/serverfarms"
        metric_name      = "CpuPercentage"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 80
      }
    }
  }

  activity_log_alert = {
    web_app_restart = {
      name     = "${module.app_service.app_service_plan["app"].name}_Restart_Web_App_Restart"
      scope_id = module.app_service.app_service_plan["app"].id
      criteria = {
        operation_name = "Microsoft.Web/serverfarms/restartSites/Action"
        category       = "Administrative"
      }
    }
  }
}
