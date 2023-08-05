################################
# User Assigned Managed ID
################################
# Define a flattened list of map keys and role assignments
# ex)
# role_assignments = [
#   { "key": "app", "role": "AcrPull" },
#   { "key": "app", "role": "Key Vault Secrets User" },
#   ... (and so on for each key and role)
# ]
locals {
  role_assignments = flatten([
    for key, value in var.user_assigned_identity : [
      for role in value.role_definition_names : {
        key  = key
        role = role
      }
    ]
  ])
}

resource "azurerm_user_assigned_identity" "this" {
  for_each            = var.user_assigned_identity
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-mngid"
  resource_group_name = var.resource_group_name
  location            = var.common.location
}

resource "azurerm_role_assignment" "this" {
  # For each combined key and role name, create a map of the role assignments to which each value corresponds.
  # ex)
  # {
  #   "app-AcrPull"                      : { "key": "app", "role": "AcrPull" },
  #   "app-Key Vault Secrets User"       : { "key": "app", "role": "Key Vault Secrets User" },
  #   ... (and so on for each key and role)
  # }
  for_each             = { for assignment in local.role_assignments : "${assignment.key}-${assignment.role}" => assignment }
  scope                = "${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.this[each.value.key].principal_id
}
