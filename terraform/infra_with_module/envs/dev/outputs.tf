output "dns_zone_name_servers" {
  value = { for key, dns_zone in module.dns.dns_zone : key => dns_zone.name_servers }
}

output "mysql_server_fqdn" {
  value = { for key, mysql in module.mysql.mysql : key => mysql.fqdn }
}

output "redis_hostname" {
  value = { for key, redis in module.redis.redis : key => redis.hostname }
}

output "vm_public_ip" {
  value = { for key, pip in module.vm.vm_public_ip : key => pip.ip_address }
}
