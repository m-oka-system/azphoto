##########################################
# Azure Database for MySQL Flexible Server
##########################################
locals {
  mysql_flexible_server_name = "${var.prefix}-${var.env}-mysql-${random_integer.num.result}"
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = local.mysql_flexible_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.db_username
  administrator_password = var.db_password
  sku_name               = var.db_size
  version                = "8.0.21"
  zone                   = "1"

  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.spoke1_db.id
  private_dns_zone_id          = azurerm_private_dns_zone.mysql.id
  geo_redundant_backup_enabled = false

  storage {
    auto_grow_enabled = true
    iops              = 360
    size_gb           = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

resource "azurerm_mysql_flexible_database" "mysql" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_0900_ai_ci"
}

resource "azurerm_mysql_flexible_server_configuration" "ssl_config" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "ON"
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${local.mysql_flexible_server_name}.private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysqlfsVnetZone"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.spoke1.id
}
