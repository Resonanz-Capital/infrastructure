terraform {
  source = "../../../modules//vnet"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment               = "dev"
  vnet_address_space        = ["10.0.0.0/16"]
  create_app_subnet         = true
  app_subnet_address_prefix = "10.0.1.0/24"
  subnets = [
    {
      name           = "GatewaySubnet"
      address_prefix = "10.0.2.0/24"
    },
    {
      name           = "app-gateway-subnet"
      address_prefix = "10.0.3.0/24"
    }
  ]
}
