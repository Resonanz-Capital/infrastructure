terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

resource "azurerm_monitor_action_group" "action_group" {
  count               = length(var.action_groups)
  name                = var.action_groups[count.index].name
  short_name          = var.action_groups[count.index].short_name
  resource_group_name = var.resource_group_name
  location            = "global"

  dynamic "email_receiver" {
    for_each = var.action_groups[count.index].email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.action_groups[count.index].webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  count               = length(var.metric_alerts)
  name                = var.metric_alerts[count.index].name
  resource_group_name = var.resource_group_name
  scopes              = var.metric_alerts[count.index].scopes
  description         = var.metric_alerts[count.index].description
  severity            = var.metric_alerts[count.index].severity
  frequency           = var.metric_alerts[count.index].frequency
  window_size         = var.metric_alerts[count.index].window_size
  enabled             = var.metric_alerts[count.index].enabled

  criteria {
    metric_namespace = var.metric_alerts[count.index].criteria.metric_namespace
    metric_name      = var.metric_alerts[count.index].criteria.metric_name
    aggregation      = var.metric_alerts[count.index].criteria.aggregation
    operator         = var.metric_alerts[count.index].criteria.operator
    threshold        = var.metric_alerts[count.index].criteria.threshold

    dynamic "dimension" {
      for_each = var.metric_alerts[count.index].criteria.dimensions
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group[0].id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}

resource "azurerm_monitor_activity_log_alert" "activity_log_alert" {
  count               = length(var.activity_log_alerts)
  name                = var.activity_log_alerts[count.index].name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.activity_log_alerts[count.index].description
  enabled             = var.activity_log_alerts[count.index].enabled

  scopes = var.activity_log_alerts[count.index].scopes

  criteria {
    operation_name = var.activity_log_alerts[count.index].criteria.operation_name
    category       = var.activity_log_alerts[count.index].criteria.category

    resource_provider = var.activity_log_alerts[count.index].criteria.resource_provider != "" ? var.activity_log_alerts[count.index].criteria.resource_provider : null
    resource_type     = var.activity_log_alerts[count.index].criteria.resource_type != "" ? var.activity_log_alerts[count.index].criteria.resource_type : null
    resource_group    = var.activity_log_alerts[count.index].criteria.resource_group != "" ? var.activity_log_alerts[count.index].criteria.resource_group : null
    resource_id       = var.activity_log_alerts[count.index].criteria.resource_id != "" ? var.activity_log_alerts[count.index].criteria.resource_id : null
    caller            = var.activity_log_alerts[count.index].criteria.caller != "" ? var.activity_log_alerts[count.index].criteria.caller : null
    level             = var.activity_log_alerts[count.index].criteria.level != "" ? var.activity_log_alerts[count.index].criteria.level : null
    status            = var.activity_log_alerts[count.index].criteria.status != "" ? var.activity_log_alerts[count.index].criteria.status : null
  }

  action {
    action_group_id = var.activity_log_alerts[count.index].action_group_id
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
  })
}
