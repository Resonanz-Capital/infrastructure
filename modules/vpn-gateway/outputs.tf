output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP address"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}

output "local_network_gateway_id" {
  description = "Local network gateway ID"
  value       = var.create_local_network_gateway ? azurerm_local_network_gateway.onprem[0].id : null
}

output "vpn_connection_id" {
  description = "VPN connection ID"
  value       = var.create_local_network_gateway ? azurerm_virtual_network_gateway_connection.vpn[0].id : null
}
