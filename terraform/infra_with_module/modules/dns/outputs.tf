output "dns_zone_name_servers" {
  value = { for key, dns_zone in azurerm_dns_zone.this : dns_zone.name => dns_zone.name_servers }
}
