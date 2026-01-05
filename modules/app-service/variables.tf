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

variable "os_type" {
  description = "OS type for App Service Plan"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "B1"
}

variable "runtime_type" {
  description = "Runtime type for app service (dotnet, node, python, etc.)"
  type        = string
  default     = "dotnet"
}

variable "runtime_version" {
  description = "Runtime version"
  type        = string
  default     = "6.0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
