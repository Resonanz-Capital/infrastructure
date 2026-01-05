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

variable "docker_image" {
  description = "Docker image name"
  type        = string
  default     = "nginx"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "sku_name" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Always on setting for app service"
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Application settings for app service"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
