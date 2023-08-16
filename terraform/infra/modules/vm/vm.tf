#################################
# Virtual machines
################################
resource "azurerm_public_ip" "this" {
  for_each            = var.vm
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-ip"
  resource_group_name = var.resource_group_name
  location            = var.common.location
  sku                 = each.value.public_ip.sku
  allocation_method   = each.value.public_ip.allocation_method
  zones               = each.value.public_ip.zones
}

resource "azurerm_network_interface" "this" {
  for_each            = var.vm
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.common.location

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet[each.value.target_subnet].id
    public_ip_address_id          = azurerm_public_ip.this[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each            = var.vm
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  computer_name       = replace("${var.common.prefix}-${var.common.env}-${each.value.name}", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.common.location
  size                = each.value.vm_size
  admin_username      = each.value.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.this[each.key].id,
  ]

  priority        = "Spot"
  max_bid_price   = -1
  eviction_policy = "Deallocate"

  allow_extension_operations      = true
  disable_password_authentication = true
  encryption_at_host_enabled      = false
  patch_mode                      = "ImageDefault"
  secure_boot_enabled             = false
  vtpm_enabled                    = false
  custom_data                     = filebase64("${path.module}/userdata.sh")

  admin_ssh_key {
    username   = each.value.vm_admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  boot_diagnostics {}

  os_disk {
    name                      = "${var.common.prefix}-${var.common.env}-${each.value.name}-osdisk"
    caching                   = each.value.os_disk_cache
    storage_account_type      = each.value.os_disk_type
    disk_size_gb              = each.value.os_disk_size
    write_accelerator_enabled = false
  }

  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     var.app_managed_id
  #   ]
  # }

  source_image_reference {
    offer     = each.value.source_image_reference.offer
    publisher = each.value.source_image_reference.publisher
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }
}
