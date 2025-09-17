resource "azurerm_monitor_action_group" "m_ag" {
  name                = "CriticalAlertsAction"
  resource_group_name = var.rg_name
  short_name          = "to_admin"

  email_receiver {
    name          = "Ali Aljaffer"
    email_address = "ali.h.aljaffer@gmail.com"
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "cpu-metricalert"
  resource_group_name = var.rg_name
  scopes              = [var.fe_app_id, var.be_app_id, var.db_id]
  description         = "Action will be triggered when CPU Utilization is greater than 80."
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.m_ag.id
  }
}

resource "azurerm_monitor_metric_alert" "memory" {
  name                = "memory-metricalert"
  resource_group_name = var.rg_name
  scopes              = [var.fe_app_id, var.be_app_id, var.db_id]
  description         = "Action will be triggered when Memory Utilization is greater than 85."
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.m_ag.id
  }
}

resource "azurerm_monitor_metric_alert" "http_errors" {
  name                = "http-errors-metricalert"
  resource_group_name = var.rg_name
  scopes              = [var.fe_app_id, var.be_app_id]
  description         = "Action will be triggered when HTTP 5xx errors exceed 10 in 5 minutes."
  severity            = 4

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "Requests"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 10

    dimension {
      name     = "StatusCodeClass"
      operator = "Include"
      values   = ["5xx"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.m_ag.id
  }
}
