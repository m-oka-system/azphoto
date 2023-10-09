################################
# Diagnostic setting
################################
data "azurerm_monitor_diagnostic_categories" "this" {
  for_each    = var.diagnostic_setting.target_resources
  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                   = var.diagnostic_setting.target_resources
  name                       = replace("${var.common.prefix}-${var.common.env}-${each.key}-diag-setting", "_", "-")
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace[var.diagnostic_setting.target_log_analytics_workspace].id
  storage_account_id         = var.storage_account[var.diagnostic_setting.target_storage_account].id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types

    content {
      category = enabled_log.value

      retention_policy {
        enabled = true
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.this[each.key].metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = true
      }
    }
  }
}
