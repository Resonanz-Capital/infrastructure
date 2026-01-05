terraform {
  source = "../../../modules//vpn-gateway"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "vnet" {
  config_path = "../vnet"

  mock_outputs = {
    subnets = {
      "GatewaySubnet" = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/GatewaySubnet"
    }
  }
}

inputs = {
  environment                  = "dev"
  gateway_subnet_id            = dependency.vnet.outputs.subnets["GatewaySubnet"]
  vpn_gateway_sku              = "VpnGw1"
  create_local_network_gateway = false
}
