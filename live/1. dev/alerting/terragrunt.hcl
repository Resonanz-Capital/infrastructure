include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//alerting"
}

dependency "app_service" {
  config_path = "../app-service"
  mock_outputs = {
    app_service_id      = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.Web/sites/mock-app"
    app_service_plan_id = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.Web/serverfarms/mock-plan"
  }
}

# ПРЕМАХНИ dependency "self" блока напълно!

inputs = {
  environment = "dev"

  action_groups = [
    {
      name       = "default-action-group"
      short_name = "defaultag"
      email_receivers = [
        {
          name          = "admin"
          email_address = "admin@example.com"
        }
      ]
      webhook_receivers = []
    }
  ]

  metric_alerts = [
    {
      name        = "high-cpu-alert"
      scopes      = [dependency.app_service.outputs.app_service_plan_id]
      description = "High CPU usage on App Service Plan"
      severity    = 3
      frequency   = "PT1M"
      window_size = "PT5M"
      enabled     = true
      criteria = {
        metric_namespace = "Microsoft.Web/serverfarms"
        metric_name      = "CpuPercentage"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 80
        dimensions       = []
      }
    }
  ]
  activity_log_alerts = []
}
