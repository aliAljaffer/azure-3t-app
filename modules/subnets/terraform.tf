
resource "azurerm_subnet" "private_endpoints" {
  name                 = "pe-subnet-private"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "agw_subnet" {
  name                 = "agw-subnet-public"
  resource_group_name  = var.rg_name
  virtual_network_name = var.rg_location
  address_prefixes     = ["10.254.0.0/24"]
}
resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet-private"
  resource_group_name  = var.rg_name
  virtual_network_name = var.rg_location
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "fe_subnet" {
  name                 = "fe-subnet-private"
  resource_group_name  = var.rg_name
  virtual_network_name = var.rg_location
  address_prefixes     = ["10.0.10.0/22"]
  # Delegation for Container apps
  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}
resource "azurerm_subnet" "be_subnet" {
  name                 = "be-subnet-private"
  resource_group_name  = var.rg_name
  virtual_network_name = var.rg_location
  address_prefixes     = ["10.0.20.0/22"]
  # Delegation for Container apps
  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}
