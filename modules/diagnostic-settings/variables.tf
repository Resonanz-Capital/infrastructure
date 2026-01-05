variable "resources" {
  description = "List of resources to enable diagnostic settings for"
  type = list(object({
    name              = string
    resource_id       = string
    log_categories    = list(string)
    metric_categories = list(string)
  }))
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "retention_days" {
  description = "Retention days for diagnostic logs"
  type        = number
  default     = 30
}
