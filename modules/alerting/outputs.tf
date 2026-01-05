output "action_group_ids" {
  description = "List of action group IDs"
  value = [
    for ag in azurerm_monitor_action_group.action_group :
    ag.id
  ]
}

output "metric_alert_ids" {
  description = "List of metric alert IDs"
  value = [
    for ma in azurerm_monitor_metric_alert.metric_alert :
    ma.id
  ]
}

output "activity_log_alert_ids" {
  description = "List of activity log alert IDs"
  value = [
    for ala in azurerm_monitor_activity_log_alert.activity_log_alert :
    ala.id
  ]
}
