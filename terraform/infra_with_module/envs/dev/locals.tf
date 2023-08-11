locals {
  # Common
  subscription_id = data.azurerm_subscription.primary.subscription_id
  tenant_id       = data.azurerm_subscription.primary.tenant_id
  random          = random_integer.num.result

  # Front Door backend
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

  # Key Vault secrets
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
