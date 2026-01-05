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

variable "sql_server_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "SQL Server administrator login"
  type        = string
}

variable "administrator_login_password" {
  description = "SQL Server administrator login password"
  type        = string
  sensitive   = true
}

variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "Database license type"
  type        = string
  default     = "LicenseIncluded"
}

variable "max_size_gb" {
  description = "Maximum size of the database in gigabytes"
  type        = number
  default     = 2
}

variable "sku_name" {
  description = "Database SKU"
  type        = string
  default     = "Basic"
}

variable "zone_redundant" {
  description = "Whether zone redundancy is enabled"
  type        = bool
  default     = false
}

variable "firewall_rules" {
  description = "List of firewall rules to create"
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
