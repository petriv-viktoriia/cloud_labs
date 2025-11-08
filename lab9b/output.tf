output "resource_group_info" {
  value = {
    name = azurerm_resource_group.az104_rg9.name
    location = azurerm_resource_group.az104_rg9.location
  }
}

output "container_instance" {
  value = {
    name = azurerm_container_group.az104_c1.name
    dns_name_label = azurerm_container_group.az104_c1.dns_name_label
    ip_address = azurerm_container_group.az104_c1.ip_address
  }
}

output "container_url" {
  value = "http://${azurerm_container_group.az104_c1.fqdn}"
}