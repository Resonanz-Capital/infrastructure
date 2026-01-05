terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count                      = length(var.resources)
  name                       = "${var.resources[count.index].name}-diagnostic-setting"
  target_resource_id         = var.resources[count.index].resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = var.resources[count.index].log_categories
    content {
      category = log.value
      enabled  = true
    }
  }

  dynamic "metric" {
    for_each = var.resources[count.index].metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}
