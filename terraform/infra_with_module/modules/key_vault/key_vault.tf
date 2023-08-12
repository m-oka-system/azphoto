################################
# Key Vault
################################
resource "azurerm_key_vault" "this" {
  for_each                   = var.key_vault
  name                       = "${var.common.prefix}-${var.common.env}-${each.value.name}-vault"
  location                   = var.common.location
  resource_group_name        = var.resource_group_name
  sku_name                   = each.value.sku_name
  tenant_id                  = var.tenant_id
  enable_rbac_authorization  = each.value.enable_rbac_authorization
  purge_protection_enabled   = each.value.purge_protection_enabled
  soft_delete_retention_days = each.value.soft_delete_retention_days
  access_policy              = []

  network_acls {
    default_action             = each.value.network_acls.default_action
    bypass                     = each.value.network_acls.bypass
    ip_rules                   = each.value.network_acls.ip_rules
    virtual_network_subnet_ids = each.value.network_acls.virtual_network_subnet_ids
  }
}
