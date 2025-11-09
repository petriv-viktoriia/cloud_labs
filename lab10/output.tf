output "resource_group_name1" {
  value = azurerm_resource_group.az104_rg_region1.name
}

output "resource_group_name2" {
  value = azurerm_resource_group.az104_rg_region2.name
}

output "azurerm_recovery_services_vault_name1" {
  value = azurerm_recovery_services_vault.az104_rsv.name
}

output "azurerm_recovery_services_vault_name2" {
  value = azurerm_recovery_services_vault.az104_rsv2.name
}

output "azurerm_backup_policy_vm_name" {
  value = azurerm_backup_policy_vm.az104_backup.name
}

output "azurerm_windows_virtual_machine_name" {
  value = azurerm_windows_virtual_machine.vm.name
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.vm.public_ip_address
}