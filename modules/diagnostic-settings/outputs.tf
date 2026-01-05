output "diagnostic_setting_ids" {
  description = "List of diagnostic setting IDs"
  value = [
    for setting in azurerm_monitor_diagnostic_setting.diagnostic_setting :
    setting.id
  ]
}
