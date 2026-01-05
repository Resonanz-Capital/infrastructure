terraform {
  source = "../../../modules//acr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment   = "dev"
  acr_sku       = "Basic"
  admin_enabled = false
}
