output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Virtual network address space"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnets" {
  description = "Map of subnet names to subnet IDs"
  value = {
    for subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}

output "app_subnet_id" {
  description = "App subnet ID"
  value       = var.create_app_subnet ? azurerm_subnet.appsubnet[0].id : null
}

output "app_subnet_name" {
  description = "App subnet name"
  value       = var.create_app_subnet ? azurerm_subnet.appsubnet[0].name : null
}
