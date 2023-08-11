################################
# Key Vault secrets
################################
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.key_vault_secrets
  name         = upper(replace(each.key, "_", "-"))
  value        = each.value
  key_vault_id = var.keyvault[var.target_key_vault].id
}
