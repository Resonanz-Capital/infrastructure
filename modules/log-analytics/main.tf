terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.project}-${var.environment}-log-analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}
