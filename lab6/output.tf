
output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.az104_rg6.name
}

output "resource_group_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.az104_rg6.location
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.core.name
}

output "subnet_names" {
  description = "Names of created subnets"
  value       = [
    azurerm_subnet.subnet0.name,
    azurerm_subnet.subnet1.name,
    azurerm_subnet.subnet2.name
  ]
}

output "network_interface_private_ips" {
  description = "Private IPs of all VM network interfaces"
  value = [
    azurerm_network_interface.vm0.private_ip_address,
    azurerm_network_interface.vm1.private_ip_address,
    azurerm_network_interface.vm2.private_ip_address
  ]
}

output "vm_names" {
  description = "Names of created virtual machines"
  value = [
    azurerm_windows_virtual_machine.vm0.name,
    azurerm_windows_virtual_machine.vm1.name,
    azurerm_windows_virtual_machine.vm2.name
  ]
}

output "vm_ids" {
  description = "IDs of all virtual machines"
  value = [
    azurerm_windows_virtual_machine.vm0.id,
    azurerm_windows_virtual_machine.vm1.id,
    azurerm_windows_virtual_machine.vm2.id
  ]
}

output "load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer"
  value       = azurerm_public_ip.az104_lbpip.ip_address
}

output "load_balancer_name" {
  description = "Name of the Load Balancer"
  value       = azurerm_lb.lb.name
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.az104_appgw.name
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.az104_gwpip.ip_address
}
