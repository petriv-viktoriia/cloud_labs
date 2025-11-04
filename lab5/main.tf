resource "azurerm_resource_group" "az104_rg5" {
  name = "az104-rg5"
  location = var.location
}

resource "azurerm_virtual_network" "core_service" {
  name = "CoreServicesVnet"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  location = azurerm_resource_group.az104_rg5.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "core_subnet" {
  name = "CoreSubnet"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  virtual_network_name = azurerm_virtual_network.core_service.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_network_interface" "core_net_interface" {
  name = "core-net-interface"
  location = azurerm_resource_group.az104_rg5.location
  resource_group_name = azurerm_resource_group.az104_rg5.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.core_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "core_vm" {
  name = "CoreServicesVM"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  location = azurerm_resource_group.az104_rg5.location
  size = "Standard_B2ms"
  admin_username = var.username
  admin_password = var.password
  network_interface_ids = [ azurerm_network_interface.core_net_interface.id ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
}


resource "azurerm_virtual_network" "manufacturing_service" {
  name = "ManufacturingVnet"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  location = azurerm_resource_group.az104_rg5.location
  address_space = [ "172.16.0.0/16" ]
}

resource "azurerm_subnet" "manufacturing_subnet" {
  name = "Manufacturing"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  virtual_network_name = azurerm_virtual_network.manufacturing_service.name
  address_prefixes = [ "172.16.0.0/24" ]
}

resource "azurerm_network_interface" "manufacturing_net_interface" {
  name = "manufacturing-net-interface"
  location = azurerm_resource_group.az104_rg5.location
  resource_group_name = azurerm_resource_group.az104_rg5.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.manufacturing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "manufacturing_vm" {
  name = "ManufacturingVM"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  location = azurerm_resource_group.az104_rg5.location
  size = "Standard_B2ms"
  admin_username = var.username
  admin_password = var.password
  network_interface_ids = [ azurerm_network_interface.manufacturing_net_interface.id ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
}

resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  name = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  virtual_network_name = azurerm_virtual_network.core_service.name
  remote_virtual_network_id = azurerm_virtual_network.manufacturing_service.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  name = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  virtual_network_name = azurerm_virtual_network.manufacturing_service.name
  remote_virtual_network_id = azurerm_virtual_network.core_service.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}


resource "azurerm_subnet" "perimeter" {
  name = "perimeter"
  address_prefixes = [ "10.0.1.0/24" ]
  resource_group_name = azurerm_resource_group.az104_rg5.name
  virtual_network_name = azurerm_virtual_network.core_service.name
}

resource "azurerm_route_table" "rt_core_services" {
  name = "rt-CoreServices"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  location = azurerm_resource_group.az104_rg5.location
  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "per_to_core" {
  name = "PerimetertoCore"
  resource_group_name = azurerm_resource_group.az104_rg5.name
  route_table_name = azurerm_route_table.rt_core_services.name
  address_prefix = "10.0.0.0/16"
  next_hop_type = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.7"
}

resource "azurerm_subnet_route_table_association" "core_assoc" {
  subnet_id = azurerm_subnet.core_subnet.id
  route_table_id = azurerm_route_table.rt_core_services.id
}