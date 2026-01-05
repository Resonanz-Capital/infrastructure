terraform {
  source = "../../../modules//log-analytics"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment       = "stage"
  sku               = "PerGB2018"
  retention_in_days = 60
}
