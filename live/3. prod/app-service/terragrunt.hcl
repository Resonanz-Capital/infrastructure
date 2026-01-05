terraform {
  source = "../../../modules//app-service"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "prod"
  os_type     = "Linux"
  sku_name    = "P1v2"
}
