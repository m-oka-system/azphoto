################################
# Web App for Containers
################################
resource "azurerm_service_plan" "this" {
  for_each            = var.app_service
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.common.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "this" {
  for_each                  = var.app_service
  name                      = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name       = var.resource_group_name
  location                  = var.common.location
  service_plan_id           = azurerm_service_plan.this[each.key].id
  virtual_network_subnet_id = var.subnet[each.value.target_subnet].id
  https_only                = each.value.https_only

  app_settings = {}

  site_config {
    always_on              = each.value.site_config.always_on
    ftps_state             = each.value.site_config.ftps_state
    vnet_route_all_enabled = each.value.site_config.vnet_route_all_enabled
  }
}
