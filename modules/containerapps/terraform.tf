resource "azurerm_container_app" "fe_app" {
  name                         = local.fe_app_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = var.rg_name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 10

    http_scale_rule {
      name                = "scale-on-requests-http"
      concurrent_requests = 20
    }
    container {
      name   = "fe-container-app"
      image  = "alialjaffer/project1-fe"
      cpu    = 1
      memory = "1Gi"
      env {
        name  = "REACT_APP_API_URL"
        value = "${local.be_app_name}:${var.be_port}/api"
      }

      liveness_probe {
        host      = "localhost"
        path      = "/health"
        port      = var.fe_port
        transport = "HTTP"
      }
      readiness_probe {
        host      = "localhost"
        path      = "/"
        port      = var.fe_port
        transport = "HTTP"
      }

    }
  }


  ingress {
    allow_insecure_connections = false
    external_enabled           = false
    target_port                = var.fe_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "be_app" {
  name                         = local.be_app_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = var.rg_name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 10

    http_scale_rule {
      name                = "scale-on-requests-http"
      concurrent_requests = 20
    }
    container {
      name   = "be-container-app"
      image  = "alialjaffer/project1-be"
      cpu    = 1
      memory = "1Gi"
      # TODO
      env {
        name  = "PORT"
        value = var.be_port
      }
      env {
        name  = "NODE_ENV"
        value = "development"
      }
      env {
        name  = "DB_SERVER"
        value = var.db_server
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "CORS_ORIGIN"
        value = "http://${local.fe_app_name}:${var.fe_port}"
      }
      env {
        name  = "DB_ENCRYPT"
        value = "true"
      }

      env {
        name  = "DB_TRUST_SERVER_CERTIFICATE"
        value = "false"
      }

      env {
        name  = "DB_CONNECTION_TIMEOUT"
        value = "30000"
      }

      env {
        name  = "JWT_EXPIRES_IN"
        value = "7d"
      }

      env {
        name  = "RATE_LIMIT_WINDOW_MS"
        value = "900000"
      }

      env {
        name  = "RATE_LIMIT_MAX_REQUESTS"
        value = "100"
      }

      # Secret environment variable
      env {
        name        = "JWT_SECRET"
        secret_name = uuid()
      }
      liveness_probe {
        host      = "localhost"
        path      = "/health"
        port      = var.be_port
        transport = "HTTP"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = false
    target_port                = var.be_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "aca-ws-analytics"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerNode"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = "app-env"
  location                   = var.rg_location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_ws.id
  resource_group_name        = var.rg_name
}

locals {
  fe_app_name = "devops2-fe-ali"
  be_app_name = "devops2-be-ali"
}
