
resource "azurerm_resource_group" "main-rg" {
  name     = "devops2-rg-ali"
  location = "West US 2"
  tags = {
    "provisioner" = "ali-terraform"
  }
}
