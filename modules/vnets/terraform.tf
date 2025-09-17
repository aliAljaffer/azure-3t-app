resource "azurerm_virtual_network" "vnet" {
  name                = "devops2-vnet-ali"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}
