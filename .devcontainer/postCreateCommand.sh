#!/usr/bin/env bash

# Add alias for Terraform
echo "Add alias to bashrc"
cat <<EOL >>~/.bashrc
# terraform
alias tf="terraform"
alias tfp="terraform plan"
alias tfv="terraform validate"
alias tff="terraform fmt -recursive"
alias tfa="terraform apply --auto-approve"
alias tfd="terraform destroy --auto-approve"
EOL

. ~/.bashrc

# Azure sign in
echo "az login"
az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
