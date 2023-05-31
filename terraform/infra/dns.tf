################################
# Azure DNS
################################
resource "azurerm_dns_zone" "public" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_txt_record" "afd_validation" {
  name                = "_dnsauth.${var.custom_domain_host_name}"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.app.validation_token
  }
}

resource "azurerm_dns_cname_record" "afd_cname" {
  name                = var.custom_domain_host_name
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.endpoint.host_name

  depends_on = [azurerm_cdn_frontdoor_route.app]
}

resource "azurerm_dns_txt_record" "webapp_validation" {
  name                = "asuid.${var.custom_domain_host_name}"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  record {
    value = azurerm_linux_web_app.app.custom_domain_verification_id
  }
}
