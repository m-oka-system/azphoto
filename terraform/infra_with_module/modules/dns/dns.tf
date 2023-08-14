################################
# Azure DNS
################################
resource "azurerm_dns_zone" "this" {
  name                = var.dns.dns_zone_name
  resource_group_name = var.resource_group_name
}
