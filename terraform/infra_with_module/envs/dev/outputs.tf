output "dns_zone_name_servers" {
  value = module.dns.dns_zone_name_servers
}

output "mysql_server_fqdn" {
  value = { for key, mysql in module.mysql.mysql : key => mysql.fqdn }
}

output "vm_public_ip" {
  value = { for key, pip in module.vm.vm_public_ip : key => pip.ip_address }
}
