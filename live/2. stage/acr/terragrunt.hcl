terraform {
  source = "../../../modules//acr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "resonanz-tmpl-stage-rg"
  environment   = "stage"
  acr_sku       = "Standard"
  admin_enabled = true
}
