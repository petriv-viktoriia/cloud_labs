output "resource_group_name" {
  value = azurerm_resource_group.az104_rg8.name
}

output "vm1_info" {
  value = {
    name = azurerm_windows_virtual_machine.az104_vm1.name
    zone = azurerm_windows_virtual_machine.az104_vm1.zone
  }
}

output "vm2_info" {
  value = {
    name = azurerm_windows_virtual_machine.az104_vm2.name
    zone = azurerm_windows_virtual_machine.az104_vm2.zone
  }
}

output "vmss_info" {
  value = {
    name = azurerm_windows_virtual_machine_scale_set.vmss1.name
    id = azurerm_windows_virtual_machine_scale_set.vmss1.id
  }
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.vmss_lb_pip.ip_address
}

output "data_disk_name" {
  value = azurerm_managed_disk.vm1_disk1.name
}