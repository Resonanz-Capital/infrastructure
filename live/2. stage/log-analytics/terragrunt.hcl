terraform {
  source = "../../../modules//log-analytics"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "resonanz-tmpl-stage-rg"
  environment       = "stage"
  sku               = "PerGB2018"
  retention_in_days = 60
}
