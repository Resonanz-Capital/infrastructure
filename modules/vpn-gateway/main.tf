terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "${var.project}-${var.environment}-vpn-gateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "${var.project}-${var.environment}-vpn-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = var.vpn_gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })

  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  count               = var.create_local_network_gateway ? 1 : 0
  name                = "${var.project}-${var.environment}-onprem-network"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = var.onprem_gateway_address
  address_space       = var.onprem_address_space

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_virtual_network_gateway_connection" "vpn" {
  count               = var.create_local_network_gateway ? 1 : 0
  name                = "${var.project}-${var.environment}-vpn-connection"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[0].id
  shared_key                 = var.shared_key
}
