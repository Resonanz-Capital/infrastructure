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

variable "capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 0
}

variable "family" {
  description = "Redis cache family"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "Redis cache SKU"
  type        = string
  default     = "Basic"
}

variable "enable_non_ssl_port" {
  description = "Enable non-SSL port"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "maxmemory_policy" {
  description = "Redis maxmemory policy"
  type        = string
  default     = "volatile-lru"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
