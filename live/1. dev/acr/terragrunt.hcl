terraform {
  source = "../../../modules//acr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment         = "dev"
  resource_group_name = "resonanz-tmpl-dev-rg"
  acr_sku             = "Basic"
  admin_enabled       = false
}
