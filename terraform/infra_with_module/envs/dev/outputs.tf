output "dns_zone_name_servers" {
  value = module.dns.dns_zone_name_servers
}

output "mysql_server_fqdn" {
  value = { for key, mysql in module.mysql.mysql : key => mysql.fqdn }
}
