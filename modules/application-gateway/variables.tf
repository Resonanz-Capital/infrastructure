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

variable "app_gateway_subnet_id" {
  description = "Application Gateway subnet ID"
  type        = string
}

variable "app_gateway_sku" {
  description = "Application Gateway SKU"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Application Gateway tier"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Application Gateway capacity"
  type        = number
  default     = 2
}

variable "zones" {
  description = "Availability zones for Application Gateway"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
