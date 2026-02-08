locals {
  storage_account_name = get_env("TF_BACKEND_STORAGE_ACCOUNT")
  container_name       = get_env("TF_BACKEND_CONTAINER_NAME", "tfstate")
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name  = "RCA-AZ-RG-TFSTATES"
    storage_account_name = local.storage_account_name
    container_name       = local.container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
EOF
}

inputs = {
  location = "westeurope"
  project  = "resonanz-tmpl"
}
