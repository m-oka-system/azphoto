################################
# Network security group
################################
resource "azurerm_network_security_group" "this" {
  for_each            = var.network_security_group
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-nsg"
  location            = var.common.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rule

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      source_address_prefixes    = join(",", security_rule.value.source_address_prefixes) == "MyIP" ? split(",", var.allowed_cidr) : security_rule.value.source_address_prefixes
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = var.network_security_group
  subnet_id                 = var.subnet[each.value.target_subnet].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
