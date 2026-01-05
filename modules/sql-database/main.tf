terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "${var.project}-${var.environment}-sql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "${var.project}-${var.environment}-sqldb"
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = var.collation
  license_type   = var.license_type
  max_size_gb    = var.max_size_gb
  sku_name       = var.sku_name
  zone_redundant = var.zone_redundant

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  count            = length(var.firewall_rules)
  name             = var.firewall_rules[count.index].name
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = var.firewall_rules[count.index].start_ip
  end_ip_address   = var.firewall_rules[count.index].end_ip
}
