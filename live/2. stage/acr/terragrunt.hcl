terraform {
  source = "../../../modules//acr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment   = "stage"
  acr_sku       = "Standard"
  admin_enabled = true
}
