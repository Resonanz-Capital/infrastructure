terraform {
  source = "../../../modules//redis-cache"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "resonanz-tmpl-stage-rg"
  environment         = "stage"
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  maxmemory_policy    = "volatile-lru"
}
