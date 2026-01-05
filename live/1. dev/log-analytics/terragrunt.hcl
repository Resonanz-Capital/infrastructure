terraform {
  source = "../../../modules//log-analytics"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "dev"
  sku               = "PerGB2018"
  retention_in_days = 30
}
