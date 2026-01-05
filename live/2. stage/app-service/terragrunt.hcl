terraform {
  source = "../../../modules//app-service"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "stage"
  os_type     = "Linux"
  sku_name    = "S1"
}
