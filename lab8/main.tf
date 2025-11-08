resource "azurerm_resource_group" "az104_rg8" {
  name = "az104-rg8"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = azurerm_resource_group.az104_rg8.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_network_interface" "nic1" {
  name = "az104-nic1"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name = "az104-nic2"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "az104_vm1" {
  name = "az104-vm1"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  size = "Standard_B1ms"
  admin_username = var.username
  admin_password = var.password
  zone = "1"
  network_interface_ids = [ azurerm_network_interface.nic1.id ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_windows_virtual_machine" "az104_vm2" {
  name = "az104-vm2"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  size = "Standard_B1s"
  admin_username = var.username
  admin_password = var.password
  zone = "2"
  network_interface_ids = [ azurerm_network_interface.nic2.id ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_managed_disk" "vm1_disk1" {
  name = "vm1-disk1"
  resource_group_name = azurerm_resource_group.az104_rg8.name
  location = azurerm_resource_group.az104_rg8.location
  storage_account_type = "StandardSSD_LRS"
  create_option = "Empty"
  disk_size_gb = 32
  zone = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1_disk_attach" {
  managed_disk_id = azurerm_managed_disk.vm1_disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.az104_vm1.id
  lun = 0
  caching = "ReadWrite"
}

resource "azurerm_virtual_network" "vmss_vnet" {
  name = "vmss-vnet"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  address_space = ["10.82.0.0/20"]
}

resource "azurerm_subnet" "vmss_subnet" {
  name = "subnet0"
  resource_group_name = azurerm_resource_group.az104_rg8.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes = ["10.82.0.0/24"]
}


resource "azurerm_windows_virtual_machine_scale_set" "vmss1" {
  name = "vmss1"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  sku = "Standard_B1s"
  instances = 2
  admin_username = var.username
  admin_password = var.password
  upgrade_mode = "Automatic"
  zones = ["1", "2", "3"]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name = "vmss-nic"
    primary = true

    ip_configuration {
      name = "internal"
      primary = true
      subnet_id = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.vmss_backend_pool.id
      ]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_network_security_group" "vmss_nsg" {
  name = "vmss1-nsg"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name

  security_rule {
    name = "allow-http"
    priority = 1010
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vmss_nsg_assoc" {
  subnet_id = azurerm_subnet.vmss_subnet.id
  network_security_group_id = azurerm_network_security_group.vmss_nsg.id
}

resource "azurerm_public_ip" "vmss_lb_pip" {
  name = "vmss-lb-pip"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  allocation_method = "Static"
  sku = "Standard"
  zones = ["1", "2", "3"]
}

resource "azurerm_lb" "vmss_lb" {
  name = "vmss-lb"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_backend_pool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss_probe" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name = "http-probe"
  protocol = "Http"
  port = 80
  request_path = "/"
}

resource "azurerm_lb_rule" "vmss_lb_rule" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name = "HTTPRule"
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_backend_pool.id]
  probe_id = azurerm_lb_probe.vmss_probe.id
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name = "vmss-autoscale"
  location = azurerm_resource_group.az104_rg8.location
  resource_group_name = azurerm_resource_group.az104_rg8.name
  target_resource_id = azurerm_windows_virtual_machine_scale_set.vmss1.id

  profile {
    name = "AutoScale"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss1.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT10M"
        time_aggregation = "Average"
        operator = "GreaterThan"
        threshold = 70
      }

      scale_action {
        direction = "Increase"
        type = "PercentChangeCount"
        value = "50"
        cooldown = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss1.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT10M"
        time_aggregation = "Average"
        operator = "LessThan"
        threshold = 30
      }

      scale_action {
        direction = "Decrease"
        type = "PercentChangeCount"
        value = "50"
        cooldown = "PT5M"
      }
    }
  }
}
