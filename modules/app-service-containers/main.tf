terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-containers-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_linux_web_app" "app_service" {
  name                = "${var.project}-${var.environment}-container-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = var.docker_image_tag
    }

    always_on = var.always_on
  }

  app_settings = merge(var.app_settings, {
    "DOCKER_ENABLE_CI" = "true"
  })

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}
