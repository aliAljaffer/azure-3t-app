resource "azurerm_application_gateway" "agw" {
  name                = "devops2-agw-ali"
  resource_group_name = var.rg_name
  location            = var.rg_location
  depends_on          = [var.fe_app_id, var.be_app_id]

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 10
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 20
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = var.subnet_agw_id
  }
  frontend_port {
    port = 80
    name = local.frontend_port_name
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }
  backend_address_pool {
    name = local.backend_address_pool_name_be

    fqdns = [var.be_app_fqdn]
  }
  backend_address_pool {
    name = local.backend_address_pool_name_fe

    fqdns = [var.fe_app_fqdn]
  }

  backend_http_settings {
    name                  = local.backend_address_pool_name_fe
    cookie_based_affinity = "Disabled"
    path                  = "/*"
    protocol              = "Http"
    request_timeout       = 60
    port                  = 80
    host_name             = var.fe_app_fqdn
    probe_name            = local.pe_probe_fe
  }
  backend_http_settings {
    name                  = local.backend_address_pool_name_be
    cookie_based_affinity = "Disabled"
    path                  = "/api/*"
    protocol              = "Http"
    request_timeout       = 60
    port                  = 3001
    host_name             = var.be_app_fqdn
    probe_name            = local.pe_probe_be
  }

  http_listener {
    protocol                       = "Http"
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name_be
    priority                   = 100
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name_be
    backend_http_settings_name = local.http_setting_name_be
    url_path_map_name          = local.pm_name
  }
  url_path_map {
    name = local.pm_name
    path_rule {
      paths                      = ["/*"]
      backend_address_pool_name  = local.backend_address_pool_name_fe
      backend_http_settings_name = local.http_setting_name_fe
      name                       = "redir-to-fe"
    }
    path_rule {
      paths                      = ["/api/*"]
      backend_address_pool_name  = local.backend_address_pool_name_be
      backend_http_settings_name = local.http_setting_name_be
      name                       = "redir-to-be"
    }
  }

  probe {
    host                                      = "127.0.0.1"
    interval                                  = 60
    name                                      = local.pe_probe_be
    port                                      = 3001
    path                                      = "/health"
    timeout                                   = 300
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
  }
  probe {
    host                                      = "127.0.0.1"
    interval                                  = 60
    name                                      = local.pe_probe_fe
    port                                      = 80
    path                                      = "/health"
    timeout                                   = 300
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
  }
}

resource "azurerm_public_ip" "agw_pip" {
  name                = "devops2-agw-pip-ali"
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"

}


locals {
  backend_address_pool_name_be   = "${var.vnet_name}-beap-be"
  backend_address_pool_name_fe   = "${var.vnet_name}-beap-fe"
  frontend_port_name             = "${var.vnet_name}-feport"
  frontend_ip_configuration_name = "${var.vnet_name}-feip"
  http_setting_name_be           = "${var.vnet_name}-be-htst-be"
  http_setting_name_fe           = "${var.vnet_name}-be-htst-fe"
  listener_name                  = "${var.vnet_name}-httplstn"
  request_routing_rule_name_fe   = "${var.vnet_name}-rqrt-fe"
  request_routing_rule_name_be   = "${var.vnet_name}-rqrt-be"
  redirect_configuration_name    = "${var.vnet_name}-rdrcfg"
  pm_name                        = "${var.vnet_name}-path-map"
  pe_probe_be                    = "${var.vnet_name}-be-probe"
  pe_probe_fe                    = "${var.vnet_name}-fe-probe"
}
