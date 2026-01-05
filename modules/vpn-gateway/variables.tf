variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "gateway_subnet_id" {
  description = "Gateway subnet ID"
  type        = string
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "create_local_network_gateway" {
  description = "Whether to create a local network gateway"
  type        = bool
  default     = false
}

variable "onprem_gateway_address" {
  description = "On-premises gateway IP address"
  type        = string
  default     = ""
}

variable "onprem_address_space" {
  description = "On-premises address space"
  type        = list(string)
  default     = []
}

variable "shared_key" {
  description = "Shared key for VPN connection"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
