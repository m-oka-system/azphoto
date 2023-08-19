terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate28226"
    container_name       = "azphoto"
    key                  = "dev.terraform.tfstate"
  }
}
