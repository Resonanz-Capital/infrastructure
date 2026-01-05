terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_windows_web_app" "app_service" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = "${var.project}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      current_stack = var.runtime_type
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_linux_web_app" "app_service" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = "${var.project}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      dotnet_version = var.runtime_type == "dotnet" ? var.runtime_version : null
      node_version   = var.runtime_type == "node" ? var.runtime_version : null
      python_version = var.runtime_type == "python" ? var.runtime_version : null
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}
