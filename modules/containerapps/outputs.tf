output "fe_app_id" {
  value = azurerm_container_app.fe_app.id
}
output "be_app_id" {
  value = azurerm_container_app.be_app.id
}

output "be_app_fqdn" {
  value = azurerm_container_app.be_app.latest_revision_fqdn
}
output "fe_app_fqdn" {
  value = azurerm_container_app.fe_app.latest_revision_fqdn
}
