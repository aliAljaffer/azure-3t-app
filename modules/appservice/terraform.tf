locals {
  fe_app_name          = "${var.resource_prefix}-fe-app-${lower(replace(var.author, " ", "-"))}"
  be_app_name          = "${var.resource_prefix}-be-app-${lower(replace(var.author, " ", "-"))}"
  fe_image_name        = "alialjaffer/project1-fe:linux_amd64"
  be_image_name        = "alialjaffer/project1-be:linux_amd64"
  service_plan_name_fe = "${var.resource_prefix}-fe-service-plan-${lower(replace(var.author, " ", "-"))}"
  service_plan_name_be = "${var.resource_prefix}-be-service-plan-${lower(replace(var.author, " ", "-"))}"
  public_access        = true
  be_sku               = "P1v3" # B1 for basic, P1v3 for autoscaling
  fe_sku               = "P1v3"
}
resource "azurerm_linux_web_app" "fe_app" {
  name                          = local.fe_app_name
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  service_plan_id               = azurerm_service_plan.service_plan_fe.id
  virtual_network_subnet_id     = var.subnet_fe_id
  public_network_access_enabled = local.public_access

  depends_on = [var.subnet_fe_id]

  site_config {
    always_on = true
    application_stack {
      docker_image_name = local.fe_image_name
    }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    ip_restriction {
      name                      = "allow-agw"
      priority                  = 100
      action                    = "Allow"
      virtual_network_subnet_id = var.subnet_agw_id
    }
    ip_restriction {
      name       = "deny-all"
      priority   = 200
      action     = "Deny"
      ip_address = "0.0.0.0/0"
    }
  }

  app_settings = {
    "REACT_APP_API_URL" = "http://${var.agw_ip}/api"
  }

}
resource "azurerm_linux_web_app" "be_app" {
  name                          = local.be_app_name
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  service_plan_id               = azurerm_service_plan.service_plan_be.id
  virtual_network_subnet_id     = var.subnet_be_id
  depends_on                    = [var.subnet_be_id, var.agw_ip]
  vnet_image_pull_enabled       = true
  public_network_access_enabled = local.public_access

  site_config {
    application_stack {
      docker_image_name   = local.be_image_name
      docker_registry_url = "https://index.docker.io"
    }
    cors {
      # "https://${local.fe_app_name}.azurewebsites.net",
      allowed_origins = [var.agw_ip]
    }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    ip_restriction {
      name                      = "allow-agw"
      priority                  = 100
      action                    = "Allow"
      virtual_network_subnet_id = var.subnet_agw_id
    }
    ip_restriction {
      name       = "deny-all"
      priority   = 200
      action     = "Deny"
      ip_address = "0.0.0.0/0"
    }

  }

  app_settings = {
    PORT                        = var.be_port
    NODE_ENV                    = "development"
    DB_SERVER                   = var.db_server
    DB_USER                     = var.db_user
    DB_PASSWORD                 = var.db_password
    DB_NAME                     = var.db_name
    CORS_ORIGIN                 = var.agw_ip
    DB_ENCRYPT                  = "true"
    DB_TRUST_SERVER_CERTIFICATE = "false"
    DB_CONNECTION_TIMEOUT       = "30000"
    JWT_EXPIRES_IN              = "7d"
    RATE_LIMIT_WINDOW_MS        = "900000"
    RATE_LIMIT_MAX_REQUESTS     = "100"
    JWT_SECRET                  = "here-is-some-random-bs-long-text-string"
  }

}

resource "azurerm_service_plan" "service_plan_be" {
  name                = local.service_plan_name_be
  resource_group_name = var.rg_name
  location            = var.rg_location
  os_type             = "Linux"
  sku_name            = local.fe_sku
}
resource "azurerm_service_plan" "service_plan_fe" {
  name                = local.service_plan_name_fe
  resource_group_name = var.rg_name
  location            = var.rg_location
  os_type             = "Linux"
  sku_name            = local.be_sku
}


# resource "azurerm_private_endpoint" "fe_pe" {
#   name                = "${var.resource_prefix}-fe-pe-${lower(replace(var.author, " ", "-"))}"
#   location            = var.rg_location
#   resource_group_name = var.rg_name
#   subnet_id           = var.private_endpoint_subnet_id

#   private_service_connection {
#     name                           = "${var.resource_prefix}-psc-fe-${lower(replace(var.author, " ", "-"))}"
#     private_connection_resource_id = azurerm_linux_web_app.fe_app.id
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.pv_dns_zone.id]
#   }

# }
# resource "azurerm_private_endpoint" "be_pe" {
#   name                = "${var.resource_prefix}-be-pe-${lower(replace(var.author, " ", "-"))}"
#   location            = var.rg_location
#   resource_group_name = var.rg_name
#   subnet_id           = var.private_endpoint_subnet_id

#   private_service_connection {
#     name                           = "${var.resource_prefix}-psc-be-${lower(replace(var.author, " ", "-"))}"
#     private_connection_resource_id = azurerm_linux_web_app.be_app.id
#     subresource_names              = ["sites"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.pv_dns_zone.id]
#   }

# }

# resource "azurerm_private_dns_zone" "pv_dns_zone" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = var.rg_name

# }
# resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
#   name                  = "${var.resource_prefix}-dns-vnet-link-${lower(replace(var.author, " ", "-"))}"
#   resource_group_name   = var.rg_name
#   private_dns_zone_name = azurerm_private_dns_zone.pv_dns_zone.name
#   virtual_network_id    = var.vnet_id

# }
