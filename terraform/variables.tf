# Input Variables
# Common
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

variable "azure_client_id" {
  type = string
}
variable "azure_tenant_id" {
  type = string
}
variable "azure_client_secret" {
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
