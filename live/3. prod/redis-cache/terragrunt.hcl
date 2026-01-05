terraform {
  source = "../../../modules//redis-cache"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment         = "prod"
  capacity            = 2
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  maxmemory_policy    = "volatile-lru"
}
