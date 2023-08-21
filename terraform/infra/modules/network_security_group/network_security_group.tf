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
      name                       = lookup(security_rule.value, "name", null)
      priority                   = lookup(security_rule.value, "priority", null)
      direction                  = lookup(security_rule.value, "direction", null)
      access                     = lookup(security_rule.value, "access", null)
      protocol                   = lookup(security_rule.value, "protocol", null)
      source_port_range          = lookup(security_rule.value, "source_port_range", null)
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      source_address_prefix      = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes    = join(",", lookup(security_rule.value, "source_address_prefixes", null)) == "MyIP" ? split(",", var.allowed_cidr) : lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix = lookup(security_rule.value, "destination_address_prefix", null)
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = var.network_security_group
  subnet_id                 = var.subnet[each.value.target_subnet].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
