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

variable "action_groups" {
  description = "List of action groups to create"
  type = list(object({
    name        = string
    short_name  = string
    email_receivers = list(object({
      name          = string
      email_address = string
    }))
    webhook_receivers = list(object({
      name        = string
      service_uri = string
    }))
  }))
  default = []
}

variable "metric_alerts" {
  description = "List of metric alerts to create"
  type = list(object({
    name        = string
    scopes      = list(string)
    description = string
    severity    = number
    frequency   = string
    window_size = string
    enabled     = bool
    criteria = object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
      dimensions = list(object({
        name     = string
        operator = string
        values   = list(string)
      }))
    })
  }))
  default = []
}

variable "activity_log_alerts" {
  description = "List of activity log alerts to create"
  type = list(object({
    name        = string
    scopes      = list(string)
    description = string
    enabled     = bool
    criteria = object({
      operation_name    = string
      category          = string
      resource_provider = string
      resource_type     = string
      resource_group    = string
      resource_id       = string
      caller            = string
      level             = string
      status            = string
    })
    action_group_id = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
