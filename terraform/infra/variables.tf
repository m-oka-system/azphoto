# Input Variables
# Common
variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "prefix" {
  type    = string
  default = "azphoto"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "allowed_cidr" {
  type = list(any)
}

# Django app
variable "secret_key" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "default_from_email" {
  type = string
}

# Azure Storage
variable "account_replication_type" {
  type    = string
  default = "LRS"
}

# Managed ID
variable "webappcontainer_roles" {
  type = list(any)
  default = [
    "AcrPull",
    "Key Vault Secrets User",
    "Storage Blob Data Contributor",
  ]
}

# Azure DNS
variable "dns_zone_name" {
  type = string
}

variable "custom_domain_host_name" {
  type    = string
  default = "www"
}

# Azure Cache for Redis
variable "redis_sku_name" {
  type    = string
  default = "Basic"
}
variable "redis_family" {
  type    = string
  default = "C"
}
variable "redis_capacity" {
  type    = string
  default = 0
}

# Azure Database for MySQL Flexible Server
variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_size" {
  type    = string
  default = "B_Standard_B1s"
}

# Web App for Containers
variable "container_registry_sku_name" {
  type    = string
  default = "Basic"
}

variable "web_app_sku_name" {
  type    = string
  default = "B1"
}

# Azure Front Door
variable "frontdoor_sku_name" {
  type    = string
  default = "Standard_AzureFrontDoor"
}
