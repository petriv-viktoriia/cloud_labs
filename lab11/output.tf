output "vm_info" {
  value = {
    name = azurerm_windows_virtual_machine.vm.name
    id = azurerm_windows_virtual_machine.vm.id
    admin_user = azurerm_windows_virtual_machine.vm.admin_username
    private_ip = azurerm_network_interface.nic.private_ip_address
    public_ip = azurerm_public_ip.pip.ip_address
    size = azurerm_windows_virtual_machine.vm.size
    resource_group = azurerm_resource_group.az104_rg11.name
    location = azurerm_resource_group.az104_rg11.location
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_workspace.id
}

output "action_group_id" {
  value = azurerm_monitor_action_group.act_group.id
}
