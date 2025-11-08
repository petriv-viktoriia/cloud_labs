output "resource_group_info" {
  value = {
    name = azurerm_resource_group.az104_rg9.name
    location = azurerm_resource_group.az104_rg9.location
  }
}

output "container_app_environment" {
  value = {
    id = azurerm_container_app_environment.container_env.id
    name = azurerm_container_app_environment.container_env.name
  }
}

output "container_app" {
  value = {
    name = azurerm_container_app.my_app.name
    fqdn = azurerm_container_app.my_app.latest_revision_fqdn
  }
}

output "container_app_url" {
  value = azurerm_container_app.my_app.latest_revision_fqdn
}