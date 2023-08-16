################################
# User Assigned Managed ID
################################
resource "azurerm_user_assigned_identity" "webappcontainer" {
  name                = "${var.prefix}-${var.env}-webappcontainer-mngid"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "webappcontainer" {
  count                = length(var.webappcontainer_roles)
  scope                = "${data.azurerm_subscription.primary.id}/resourceGroups/${azurerm_resource_group.rg.name}"
  role_definition_name = var.webappcontainer_roles[count.index]
  principal_id         = azurerm_user_assigned_identity.webappcontainer.principal_id
}
