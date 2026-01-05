terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_redis_cache" "redis" {
  name                = "${var.project}-${var.environment}-redis"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version

  redis_configuration {
    maxmemory_policy = var.maxmemory_policy
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })

  timeouts {
    create = "60m"
    update = "60m"
  }
}
