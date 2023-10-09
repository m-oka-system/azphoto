# Azure
variable "tfc_azure_audience" {
  type    = string
  default = "api://AzureADTokenExchange"
}

variable "tfc_hostname" {
  type    = string
  default = "app.terraform.io"
}

# Terraform Cloud
variable "tfc_organization_name" {
  type = string
}

variable "tfc_project_name" {
  type    = string
  default = "Default Project"
}

variable "tfc_workspace_name" {
  type    = string
  default = "azphoto"
}

# GitHub
variable "github_repo_name" {
  type    = string
  default = "azphoto"
}

variable "github_token" {
  type = string
}

variable "tfc_encrypted_token" {
  type = string
}

# Application and Infrastructure
variable "allowed_cidr" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "default_from_email" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "public_key" {
  type = string
}

variable "keyvault_name" {
  type = string
}
