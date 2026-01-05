output "sql_server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.sql_server.id
}

output "sql_server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  description = "SQL Server fully qualified domain name"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "SQL Database ID"
  value       = azurerm_mssql_database.sql_database.id
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = azurerm_mssql_database.sql_database.name
}
