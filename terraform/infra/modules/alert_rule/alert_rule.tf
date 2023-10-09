################################
# Logic Apps
################################
data "azurerm_managed_api" "teams" {
  name     = "teams"
  location = var.common.location
}

resource "azurerm_api_connection" "teams" {
  name                = "teams"
  resource_group_name = var.resource_group_name
  managed_api_id      = data.azurerm_managed_api.teams.id
  display_name        = "Azure Monitor Account"
}

resource "azurerm_logic_app_workflow" "this" {
  name                = "${var.common.prefix}-${var.common.env}-logic"
  location            = var.common.location
  resource_group_name = var.resource_group_name

  workflow_parameters = {
    "$connections" = jsonencode(
      {
        type         = "Object"
        defaultValue = {}
      }
    )
  }

  parameters = {
    "$connections" = jsonencode({
      "teams" : {
        "connectionId"   = azurerm_api_connection.teams.id
        "connectionName" = azurerm_api_connection.teams.name
        "id"             = azurerm_api_connection.teams.managed_api_id
      }
    })
  }
}

resource "azurerm_logic_app_trigger_http_request" "this" {
  name         = "http-request"
  logic_app_id = azurerm_logic_app_workflow.this.id
  schema       = file("${path.module}/common-alert-schema.json")
}

resource "azurerm_logic_app_action_custom" "action-post-to-teams" {
  name         = "チャットまたはチャネルでメッセージを投稿する"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = templatefile(
    "${path.module}/post-to-teams.json",
    {
      group_id   = var.microsoft_teams_group_id
      channel_id = var.microsoft_teams_channel_id
    }
  )
}

################################
# Alert Rule
################################
resource "azurerm_monitor_action_group" "this" {
  name                = "${var.common.prefix}-${var.common.env}-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = replace("${var.common.prefix}-${var.common.env}-ag", "-", "")

  logic_app_receiver {
    name                    = var.action_group.receiver_name
    resource_id             = azurerm_logic_app_workflow.this.id
    callback_url            = azurerm_logic_app_trigger_http_request.this.callback_url
    use_common_alert_schema = var.action_group.use_common_alert_schema
  }
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each            = var.metric_alert
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope_id]
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size

  criteria {
    metric_namespace = each.value.criteria.metric_namespace
    metric_name      = each.value.criteria.metric_name
    aggregation      = each.value.criteria.aggregation
    operator         = each.value.criteria.operator
    threshold        = each.value.criteria.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each            = var.activity_log_alert
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scopes              = [each.value.scope_id]

  criteria {
    operation_name = each.value.criteria.operation_name
    category       = each.value.criteria.category
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
