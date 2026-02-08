terraform {
  source = "../../../modules//app-service"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment         = "dev"
  resource_group_name = "resonanz-tmpl-dev-rg"
  os_type             = "Linux"
  sku_name            = "B1"
}
