output "resource_group" {
  value = {
    id = azurerm_resource_group.az104_rg3.id
    name = azurerm_resource_group.az104_rg3.name
    location = azurerm_resource_group.az104_rg3.location
    tags = azurerm_resource_group.az104_rg3.tags
  }
}

output "managed_disks" {
  value = {
    for k, v in azurerm_managed_disk.disks : k => {
      id   = v.id
      name = v.name
      size = v.disk_size_gb
    }
  }
}
