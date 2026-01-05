terraform {
  source = "../../../modules//diagnostic-settings"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "log_analytics" {
  config_path = "../log-analytics"

  mock_outputs = {
    log_analytics_workspace_id = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.OperationalInsights/workspaces/mock-law"
  }
}

dependency "app_service" {
  config_path = "../app-service"

  mock_outputs = {
    app_service_id = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.Web/sites/mock-app"
  }
}

dependency "storage_account" {
  config_path = "../storage-account"

  mock_outputs = {
    storage_account_id = "/subscriptions/mock-sub/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
  }
}

dependencies {
  paths = [
    "../log-analytics",
    "../app-service",
    "../storage-account"
  ]
}

inputs = {
  environment                = "stage"
  log_analytics_workspace_id = dependency.log_analytics.outputs.log_analytics_workspace_id
  retention_days             = 60
  resources = [
    {
      name              = "app-service"
      resource_id       = dependency.app_service.outputs.app_service_id
      log_categories    = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs"]
      metric_categories = ["AllMetrics"]
    },
    {
      name              = "storage-account"
      resource_id       = dependency.storage_account.outputs.storage_account_id
      log_categories    = []
      metric_categories = ["Transaction", "Capacity"]
    }
  ]
}
