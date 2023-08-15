################################
# Front Door
################################
locals {
  front_door_profile_name = "${var.common.prefix}-${var.common.env}-afd"
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                     = "${var.common.prefix}-${var.common.env}-afd"
  resource_group_name      = var.resource_group_name
  sku_name                 = var.frontdoor.sku_name
  response_timeout_seconds = var.frontdoor.response_timeout_seconds
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "${local.front_door_profile_name}-${var.frontdoor_endpoint.name}-ep"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each                 = var.frontdoor_origin_group
  name                     = "${local.front_door_profile_name}-${each.value.name}-backend"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled = each.value.session_affinity_enabled

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  health_probe {
    interval_in_seconds = each.value.health_probe.interval_in_seconds
    path                = each.value.health_probe.path
    protocol            = each.value.health_probe.protocol
    request_type        = each.value.health_probe.request_type
  }

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each                      = var.frontdoor_origin
  name                          = "${local.front_door_profile_name}-${each.value.name}-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.target_frontdoor_origin_group].id
  enabled                       = true

  certificate_name_check_enabled = true

  host_name          = var.backend_origins[each.value.target_backend_origin].host_name
  http_port          = each.value.http_port
  https_port         = each.value.https_port
  origin_host_header = var.backend_origins[each.value.target_backend_origin].origin_host_header
  priority           = each.value.priority
  weight             = each.value.weight
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each                      = var.frontdoor_route
  name                          = "${local.front_door_profile_name}-${each.value.name}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.target_frontdoor_origin_group].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this[each.value.target_frontdoor_origin].id]
  cdn_frontdoor_rule_set_ids    = []
  enabled                       = true

  forwarding_protocol    = each.value.forwarding_protocol
  https_redirect_enabled = each.value.https_redirect_enabled
  patterns_to_match      = each.value.patterns_to_match
  supported_protocols    = each.value.supported_protocols

  # cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.app.id]
  link_to_default_domain = each.value.link_to_default_domain

  dynamic "cache" {
    for_each = lookup(each.value, "cache", null) != null ? [each.value.cache] : []

    content {
      compression_enabled           = cache.value.compression_enabled
      query_string_caching_behavior = cache.value.query_string_caching_behavior
      query_strings                 = cache.value.query_strings
      content_types_to_compress     = cache.value.content_types_to_compress
    }
  }
}

# # Web Application Firewall
# resource "azurerm_cdn_frontdoor_security_policy" "this" {
#   for_each                 = var.frontdoor_security_policy
#   name                     = "${local.front_door_profile_name}-${each.value.name}-secpolicy"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

#   security_policies {
#     firewall {
#       cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this[each.value.target_firewall_policy].id

#       association {
#         domain {
#           cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id
#         }

#         patterns_to_match = ["/*"]
#       }
#     }
#   }
# }

# resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
#   for_each                          = var.frontdoor_firewall_policy
#   name                              = each.value.name
#   resource_group_name               = var.resource_group_name
#   sku_name                          = each.value.sku_name
#   enabled                           = true
#   mode                              = each.value.mode
#   custom_block_response_status_code = each.value.custom_block_response_status_code

#   dynamic "custom_rule" {
#     for_each = var.frontdoor_firewall_custom_rule

#     content {
#       name     = custom_rule.value.rule_name
#       enabled  = true
#       priority = custom_rule.value.priority
#       type     = "MatchRule"
#       action   = "Block"

#       match_condition {
#         match_variable     = "RemoteAddr"
#         operator           = "IPMatch"
#         negation_condition = true # 含まない場合
#         match_values       = custom_rule.value.match_values
#       }
#     }
#   }
# }
