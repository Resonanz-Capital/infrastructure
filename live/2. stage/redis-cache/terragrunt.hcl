terraform {
  source = "../../../modules//redis-cache"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment         = "stage"
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  maxmemory_policy    = "volatile-lru"
}
