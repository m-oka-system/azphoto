################################
# Web App for Containers
################################
resource "azurerm_service_plan" "this" {
  for_each            = var.service_plan
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.common.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "this" {
  for_each                        = var.app_service
  name                            = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name             = var.resource_group_name
  location                        = var.common.location
  service_plan_id                 = azurerm_service_plan.this[each.value.target_service_plan].id
  virtual_network_subnet_id       = var.subnet[each.value.target_subnet].id
  https_only                      = each.value.https_only
  public_network_access_enabled   = each.value.public_network_access_enabled
  key_vault_reference_identity_id = var.identity[each.value.target_user_assigned_identity].id

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity[each.value.target_user_assigned_identity].id
    ]
  }

  app_settings = var.app_settings

  site_config {
    always_on                                     = each.value.site_config.always_on
    ftps_state                                    = each.value.site_config.ftps_state
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    scm_use_main_ip_restriction                   = false
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.identity[each.value.target_user_assigned_identity].client_id

    dynamic "ip_restriction" {
      for_each = each.value.ip_restriction

      content {
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        action      = ip_restriction.value.action
        ip_address  = ip_restriction.value.ip_address
        service_tag = ip_restriction.value.service_tag

        dynamic "headers" {
          for_each = ip_restriction.key == "frontdoor" ? [true] : []

          content {
            x_azure_fdid = [
              var.frontdoor_profile.resource_guid
            ]
            x_fd_health_probe = []
            x_forwarded_for   = []
            x_forwarded_host  = []
          }
        }
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = each.value.scm_ip_restriction

      content {
        name        = scm_ip_restriction.value.name
        priority    = scm_ip_restriction.value.priority
        action      = scm_ip_restriction.value.action
        ip_address  = scm_ip_restriction.value.ip_address
        service_tag = scm_ip_restriction.value.service_tag
      }
    }

    application_stack {
      # Initial container image (overwritten by CI/CD)
      docker_image_name   = "appsvc/staticsite:latest"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name,
      site_config[0].application_stack[0].docker_registry_url
    ]
  }
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each            = var.dns
  hostname            = "${var.dns[each.key].subdomain}.${var.dns[each.key].dns_zone_name}"
  app_service_name    = azurerm_linux_web_app.this[each.key].name
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_dns_txt_record.web_app_validation
  ]
}

resource "azurerm_dns_txt_record" "web_app_validation" {
  for_each            = var.dns
  name                = "asuid.${var.dns[each.key].subdomain}"
  zone_name           = var.dns_zone[each.key].name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  record {
    value = azurerm_linux_web_app.this[each.key].custom_domain_verification_id
  }
}
