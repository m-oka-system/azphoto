################################
# Azure Cache for Redis
################################
resource "azurerm_redis_cache" "this" {
  for_each                      = var.redis
  name                          = "${var.common.prefix}-${var.common.env}-${each.value.name}-${var.random}"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  sku_name                      = each.value.sku_name
  family                        = each.value.family
  capacity                      = each.value.capacity
  redis_version                 = each.value.redis_version
  public_network_access_enabled = each.value.public_network_access_enabled
  enable_non_ssl_port           = each.value.enable_non_ssl_port
  minimum_tls_version           = each.value.minimum_tls_version
}
