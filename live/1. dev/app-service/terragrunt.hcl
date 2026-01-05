terraform {
  source = "../../../modules//app-service"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "dev"
  os_type  = "Linux"
  sku_name = "B1"
}
