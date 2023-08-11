locals {
  common = {
    subscription_id = data.azurerm_subscription.primary.subscription_id
    tenant_id       = data.azurerm_subscription.primary.tenant_id
    random          = random_integer.num.result
  }

  front_door = {
    backend_origins = {
      app = {
        host_name          = module.app_service.app_service["app"].default_hostname
        origin_host_header = module.app_service.app_service["app"].default_hostname
      }
      blob = {
        host_name          = module.storage.storage["app"].primary_blob_host
        origin_host_header = module.storage.storage["app"].primary_blob_host
      }
    }
  }

  key_vault = {
    app_key_vaul_secrets = {
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
    app_blob = {
      name                           = module.storage.storage["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "blob"
      subresource_names              = ["blob"]
      private_connection_resource_id = module.storage.storage["app"].id
    }
    app_key_vault = {
      name                           = module.keyvault.keyvault["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "key_vault"
      subresource_names              = ["vault"]
      private_connection_resource_id = module.keyvault.keyvault["app"].id
    }
    app_redis = {
      name                           = module.redis.redis["app"].name
      target_subnet                  = "pe"
      target_private_dns_zone        = "redis"
      subresource_names              = ["redisCache"]
      private_connection_resource_id = module.redis.redis["app"].id
    }
  }
}
