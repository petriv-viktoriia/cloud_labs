output "core_virtual_network" {
  value = {
    name = azurerm_virtual_network.core_service.name
    address_space = azurerm_virtual_network.core_service.address_space
    subnet_name = azurerm_subnet.core_subnet.name
    subnet_prefix = azurerm_subnet.core_subnet.address_prefixes
  }
}

output "manufacturing_virtual_network" {
  value = {
    name = azurerm_virtual_network.manufacturing_service.name
    address_space = azurerm_virtual_network.manufacturing_service.address_space
    subnet_name = azurerm_subnet.manufacturing_subnet.name
    subnet_prefix = azurerm_subnet.manufacturing_subnet.address_prefixes
  }
}

output "core_vm_info" {
  value = {
    name = azurerm_windows_virtual_machine.core_vm.name
    private_ip = azurerm_network_interface.core_net_interface.ip_configuration[0].private_ip_address
    vm_size = azurerm_windows_virtual_machine.core_vm.size
    os_disk_type = azurerm_windows_virtual_machine.core_vm.os_disk[0].storage_account_type
    admin_username = azurerm_windows_virtual_machine.core_vm.admin_username
  }
}

output "manufacturing_vm_info" {
  value = {
    name = azurerm_windows_virtual_machine.manufacturing_vm.name
    private_ip = azurerm_network_interface.manufacturing_net_interface.ip_configuration[0].private_ip_address
    vm_size = azurerm_windows_virtual_machine.manufacturing_vm.size
    os_disk_type = azurerm_windows_virtual_machine.manufacturing_vm.os_disk[0].storage_account_type
    admin_username = azurerm_windows_virtual_machine.manufacturing_vm.admin_username
  }
}

output "route_table_info" {
  value = {
    name = azurerm_route_table.rt_core_services.name
    location = azurerm_route_table.rt_core_services.location
    associated_core_subnet = azurerm_subnet_route_table_association.core_assoc.subnet_id
  }
}