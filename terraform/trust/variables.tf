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
