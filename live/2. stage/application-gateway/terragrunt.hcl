terraform {
  source = "../../../modules//application-gateway"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "vnet" {
  config_path = "../vnet"

  mock_outputs = {
    subnets = {
      "app-gateway-subnet" = "/subscriptions/00000000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/app-gateway-subnet"
    }
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  environment           = "stage"
  app_gateway_subnet_id = dependency.vnet.outputs.subnets["app-gateway-subnet"]
  app_gateway_sku       = "Standard_v2"
  app_gateway_tier      = "Standard_v2"
  capacity              = 2
}
