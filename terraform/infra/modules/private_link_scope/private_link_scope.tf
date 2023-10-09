###################################
# Azure Monitor Private Link Scope
###################################
resource "azurerm_monitor_private_link_scope" "this" {
  name                = "${var.common.prefix}-${var.common.env}-ampls"
  resource_group_name = var.resource_group_name
}

resource "azurerm_monitor_private_link_scoped_service" "this" {
  for_each            = var.private_link_scoped_service
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = each.value.linked_resource_id
}
