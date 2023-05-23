terraform {
  required_version = "~> 1.4.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.39.0"
    }
    tfe = {
      version = "~> 0.38.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.25.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "github" {
  token = var.github_token
}

##################################
# Azure subscription and Azure AD
##################################
data "azurerm_subscription" "current" {}

locals {
  tfc_roles = [
    "Contributor",
    "Key Vault Administrator",
    "User Access Administrator"
  ]
}

resource "azuread_application" "tfc_application" {
  display_name = "terraform-cloud"
}

resource "azuread_service_principal" "tfc_service_principal" {
  application_id = azuread_application.tfc_application.application_id
}

resource "azurerm_role_assignment" "tfc_role_assignment" {
  count                = length(local.tfc_roles)
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = local.tfc_roles[count.index]
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_plan" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "tfc-federated-credential-plan"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_apply" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "tfc-federated-credential-apply"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
}

##################################
# Terraform Cloud
##################################
data "tfe_organization" "org" {
  name = var.tfc_organization_name
}

resource "tfe_workspace" "infra" {
  name                  = var.tfc_workspace_name
  organization          = data.tfe_organization.org.name
  auto_apply            = false
  file_triggers_enabled = false
  queue_all_runs        = false
  execution_mode        = "remote"
}

# Workspace variables
resource "tfe_variable" "azure_provider_auth" {
  key          = "TFC_AZURE_PROVIDER_AUTH"
  value        = true
  category     = "env"
  workspace_id = tfe_workspace.infra.id
}

resource "tfe_variable" "azure_client_id" {
  key          = "TFC_AZURE_RUN_CLIENT_ID"
  value        = azuread_application.tfc_application.application_id
  category     = "env"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "azure_subscription_id" {
  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.azurerm_subscription.current.subscription_id
  category     = "env"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "azure_tenant_id" {
  key          = "ARM_TENANT_ID"
  value        = data.azurerm_subscription.current.tenant_id
  category     = "env"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "client_public_ip" {
  key          = "client_public_ip"
  value        = jsonencode(var.client_public_ip)
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
  hcl          = true
}

resource "tfe_variable" "secret_key" {
  key          = "secret_key"
  value        = var.secret_key
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "sendgrid_api_key" {
  key          = "sendgrid_api_key"
  value        = var.sendgrid_api_key
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "default_from_email" {
  key          = "default_from_email"
  value        = var.default_from_email
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "dns_zone_name" {
  key          = "dns_zone_name"
  value        = var.dns_zone_name
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "db_name" {
  key          = "db_name"
  value        = var.db_name
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "db_username" {
  key          = "db_username"
  value        = var.db_username
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

resource "tfe_variable" "db_password" {
  key          = "db_password"
  value        = var.db_password
  category     = "terraform"
  workspace_id = tfe_workspace.infra.id
  sensitive    = true
}

##################################
# GitHub
##################################
resource "github_actions_secret" "tf_api_token" {
  repository      = var.github_repo_name
  secret_name     = "TF_API_TOKEN"
  encrypted_value = var.tfc_encrypted_token # gh secret set TF_API_TOKEN --no-store
}
