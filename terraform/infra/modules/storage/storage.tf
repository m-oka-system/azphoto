################################
# Storage Account
################################
resource "azurerm_storage_account" "this" {
  for_each                      = var.storage
  name                          = replace("${var.common.prefix}${var.common.env}${each.value.name}${var.random}", "-", "")
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  account_tier                  = each.value.account_tier
  account_kind                  = each.value.account_kind
  account_replication_type      = each.value.account_replication_type
  access_tier                   = each.value.access_tier
  enable_https_traffic_only     = each.value.enable_https_traffic_only
  public_network_access_enabled = each.value.public_network_access_enabled
  is_hns_enabled                = each.value.is_hns_enabled

  blob_properties {
    versioning_enabled       = each.value.blob_properties.versioning_enabled
    change_feed_enabled      = each.value.blob_properties.change_feed_enabled
    last_access_time_enabled = each.value.blob_properties.last_access_time_enabled

    delete_retention_policy {
      days = each.value.blob_properties.delete_retention_policy
    }

    container_delete_retention_policy {
      days = each.value.blob_properties.container_delete_retention_policy
    }
  }

  network_rules {
    default_action             = each.value.network_rules.default_action
    bypass                     = each.value.network_rules.bypass
    ip_rules                   = join(",", lookup(each.value.network_rules, "ip_rules", null)) == "MyIP" ? toset(concat(split(",", var.allowed_cidr), [var.client_ip_address])) : lookup(each.value.network_rules, "ip_rules", null)
    virtual_network_subnet_ids = each.value.network_rules.virtual_network_subnet_ids
  }
}

resource "azurerm_storage_container" "this" {
  for_each              = var.blob_container
  name                  = each.value.container_name
  storage_account_name  = azurerm_storage_account.this[each.value.storage_account_key].name
  container_access_type = each.value.container_access_type
}
