terraform {
  source = "../../../modules//acr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment   = "prod"
  acr_sku       = "Premium"
  admin_enabled = true
}
