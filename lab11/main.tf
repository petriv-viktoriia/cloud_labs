resource "azurerm_resource_group" "az104_rg11" {
  name = "az104-rg11"
  location = var.loc
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name
}

resource "azurerm_subnet" "subnet" {
  name = "subnet"
  resource_group_name = azurerm_resource_group.az104_rg11.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name = "pip"
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg"
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name

  security_rule {
    name = "Allow-HTTP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name = "nic"
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name

  ip_configuration {
    name = "nic_configuration"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name = "az104-11-vm"
  admin_username = var.username
  admin_password = var.password
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_D2s_v3"

  os_disk {
    name = "myOsDisk"
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

resource "azurerm_log_analytics_workspace" "log_workspace" {
  name = "az104-rg11-log-workspace"
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name
  sku = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_data_collection_rule" "dc_rule" {
  name = "az104-data-collection-rule"
  location = azurerm_resource_group.az104_rg11.location
  resource_group_name = azurerm_resource_group.az104_rg11.name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
      name = "log-analytics"
    }
  }

  data_flow {
    streams = ["Microsoft-InsightsMetrics"]
    destinations = ["log-analytics"]
  }

  data_sources {
    performance_counter {
      streams = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [ "\\VmInsights\\DetailedMetrics"]
      name = "eventLogsDataSource"
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dc_rule_vm" {
  name = "dc-rule-vm-association"
  target_resource_id = azurerm_windows_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dc_rule.id
}

resource "azurerm_virtual_machine_extension" "agent" {
  name = "monitor-agent"
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  publisher = "Microsoft.Azure.Monitor"
  type = "AzureMonitorWindowsAgent"
  type_handler_version = "1.10"
  auto_upgrade_minor_version = "true"
}

resource "azurerm_monitor_action_group" "act_group" {
  name = "Alert the operations team"
  short_name = "AlertOps"
  resource_group_name = azurerm_resource_group.az104_rg11.name

  email_receiver {
    name = "VM was deleted"
    email_address = var.email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_activity_log_alert" "alert" {
  name = "VM was deleted"
  location = "global"
  resource_group_name = azurerm_resource_group.az104_rg11.name
  scopes = [azurerm_resource_group.az104_rg11.id]
  description = "A VM in your resource group was deleted"
  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/delete"
    category = "Administrative"
  }
  action {
    action_group_id = azurerm_monitor_action_group.act_group.id
  }
}

resource "azurerm_monitor_alert_processing_rule_suppression" "maintenance" {
  name = "PlannedMaintenance"
  description = "Suppress notifications during planned maintenance."
  resource_group_name = azurerm_resource_group.az104_rg11.name
  scopes = [ azurerm_resource_group.az104_rg11.id ]

  schedule {
    recurrence {
      daily {
        start_time = "22:00:00"
        end_time = "07:00:00"
      }
    }
    time_zone = "FLE Standard Time"
  }
}
