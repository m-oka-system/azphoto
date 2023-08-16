################################
# Front Door
################################
locals {
  front_door_profile_name           = "${var.prefix}-${var.env}-afd"
  front_door_endpoint_name          = "${var.prefix}-${var.env}-afd-endpoint"
  front_door_app_origin_group_name  = "${var.prefix}-${var.env}-afd-app-backend"
  front_door_app_origin_name        = "${var.prefix}-${var.env}-afd-app-origin"
  front_door_app_route_name         = "${var.prefix}-${var.env}-afd-app-route"
  front_door_blob_origin_group_name = "${var.prefix}-${var.env}-afd-blob-backend"
  front_door_blob_origin_name       = "${var.prefix}-${var.env}-afd-blob-origin"
  front_door_blob_route_name        = "${var.prefix}-${var.env}-afd-blob-route"
}

resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                     = local.front_door_profile_name
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = var.frontdoor_sku_name
  response_timeout_seconds = 60
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
}

# App route (to App Service)
resource "azurerm_cdn_frontdoor_origin_group" "app" {
  name                     = local.front_door_app_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  session_affinity_enabled = false

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "app" {
  name                          = local.front_door_app_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app.id
  enabled                       = true

  certificate_name_check_enabled = true

  host_name          = azurerm_linux_web_app.app.default_hostname
  http_port          = 80
  https_port         = 443
  origin_host_header = local.service_fqdn
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_route" "app" {
  name                          = local.front_door_app_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app.id]
  cdn_frontdoor_rule_set_ids    = []
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.app.id]
  link_to_default_domain          = true
}

# Static contents route (to BLOB storage)
resource "azurerm_cdn_frontdoor_origin_group" "blob" {
  name                     = local.front_door_blob_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  session_affinity_enabled = false

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "blob" {
  name                          = local.front_door_blob_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.blob.id
  enabled                       = true

  certificate_name_check_enabled = true

  host_name          = azurerm_storage_account.app.primary_blob_host
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_storage_account.app.primary_blob_host
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_route" "blob" {
  name                          = local.front_door_blob_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.blob.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.blob.id]
  cdn_frontdoor_rule_set_ids    = []
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match = [
    "/media/*",
    "/static/*",
  ]
  supported_protocols = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.app.id]
  link_to_default_domain          = true

  cache {
    compression_enabled           = true
    query_string_caching_behavior = "IgnoreQueryString"
    query_strings                 = []
    content_types_to_compress     = ["text/html", "text/css", "text/javascript"]
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "app" {
  name                     = replace(local.service_fqdn, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  dns_zone_id              = azurerm_dns_zone.public.id
  host_name                = local.service_fqdn

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "app" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.app.id
  cdn_frontdoor_route_ids = [
    azurerm_cdn_frontdoor_route.app.id,
    azurerm_cdn_frontdoor_route.blob.id,
  ]
}
