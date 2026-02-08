terraform {
  source = "../../../modules//app-service"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "resonanz-tmpl-stage-rg"
  environment = "stage"
  os_type     = "Linux"
  sku_name    = "S1"
}
