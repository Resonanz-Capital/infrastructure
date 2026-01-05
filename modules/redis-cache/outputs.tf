output "redis_cache_id" {
  description = "Redis Cache ID"
  value       = azurerm_redis_cache.redis.id
}

output "redis_cache_name" {
  description = "Redis Cache name"
  value       = azurerm_redis_cache.redis.name
}

output "redis_cache_hostname" {
  description = "Redis Cache hostname"
  value       = azurerm_redis_cache.redis.hostname
}

output "redis_cache_port" {
  description = "Redis Cache port"
  value       = azurerm_redis_cache.redis.port
}

output "redis_cache_ssl_port" {
  description = "Redis Cache SSL port"
  value       = azurerm_redis_cache.redis.ssl_port
}

output "redis_cache_primary_access_key" {
  description = "Redis Cache primary access key"
  value       = azurerm_redis_cache.redis.primary_access_key
  sensitive   = true
}

output "redis_cache_secondary_access_key" {
  description = "Redis Cache secondary access key"
  value       = azurerm_redis_cache.redis.secondary_access_key
  sensitive   = true
}
