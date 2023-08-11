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
}
