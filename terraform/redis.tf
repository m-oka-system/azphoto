################################
# Azure Cache for Redis
################################
resource "azurerm_redis_cache" "redis" {
  name                          = "${var.prefix}-${var.env}-redis-${random_integer.num.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  sku_name                      = var.redis_sku_name
  family                        = var.redis_family
  capacity                      = var.redis_capacity
  redis_version                 = 6
  public_network_access_enabled = false
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
}
