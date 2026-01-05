terraform {
  source = "../../../modules//redis-cache"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "dev"
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  maxmemory_policy    = "volatile-lru"
}
