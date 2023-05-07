terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.33.0"
    }
  }
  cloud {
    organization = "m-oka-system"

    workspaces {
      name = "azphoto"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "random_integer" "num" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.env}-rg"
  location = var.location
}
