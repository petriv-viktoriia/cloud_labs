resource "azurerm_resource_group" "az104_rg6" {
  name = "az104-rg6"
  location = var.location
}

resource "azurerm_virtual_network" "core" {
  name = "az104-06-vnet1"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  location = azurerm_resource_group.az104_rg6.location
  address_space = [ "10.60.0.0/22" ]
}

resource "azurerm_subnet" "subnet0" {
  name = "subnet0"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes = [ "10.60.0.0/24" ]
}

resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes = [ "10.60.1.0/24" ]
}

resource "azurerm_subnet" "subnet2" {
  name = "subnet2"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes = [ "10.60.2.0/24" ]
}

resource "azurerm_network_security_group" "nsg" {
  name = "az104-nsg"
  location = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name = "Allow-HTTP"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_interface" "vm0" {
  name                = "az104-06-nic0"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.60.0.4"
  }
}

resource "azurerm_network_interface" "vm1" {
  name                = "az104-06-nic1"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.60.1.4"
  }
}

resource "azurerm_network_interface" "vm2" {
  name                = "az104-06-nic2"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.60.2.4"
  }
}

resource "azurerm_network_interface_security_group_association" "vm0" {
  network_interface_id      = azurerm_network_interface.vm0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "vm1" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "vm2" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "az104-06-vm0"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  size                = "Standard_B1ms"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [azurerm_network_interface.vm0.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "az104-06-vm1"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  size                = "Standard_B1ms"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [azurerm_network_interface.vm1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "az104-06-vm2"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  size                = "Standard_B1ms"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [azurerm_network_interface.vm2.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "iis_vm0" {
  name                 = "IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm0.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools; Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value 'Hello World from az104-06-vm0'"
  })
}

resource "azurerm_virtual_machine_extension" "iis_vm1" {
  name                 = "IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools; New-Item -ItemType Directory -Force -Path 'C:\\inetpub\\wwwroot\\image'; Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value 'Hello World from az104-06-vm1'; Set-Content -Path 'C:\\inetpub\\wwwroot\\image\\index.html' -Value 'Images from az104-06-vm1'"
  })
}

resource "azurerm_virtual_machine_extension" "iis_vm2" {
  name                 = "IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools; New-Item -ItemType Directory -Force -Path 'C:\\inetpub\\wwwroot\\video'; Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value 'Hello World from az104-06-vm2'; Set-Content -Path 'C:\\inetpub\\wwwroot\\video\\index.html' -Value 'Video from az104-06-vm2'"
  })
}

resource "azurerm_public_ip" "az104_lbpip" {
  name                = "az104-lbpip"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "az104-lb"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "az104-fe"
    public_ip_address_id = azurerm_public_ip.az104_lbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "az104_be" {
  name = "az104-be"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm0_lb" {
  network_interface_id    = azurerm_network_interface.vm0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az104_be.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1_lb" {
  network_interface_id    = azurerm_network_interface.vm1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az104_be.id
}

resource "azurerm_lb_probe" "az104_hp" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "az104-hp"
  port            = 80
  interval_in_seconds = 5
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "az104_lbrule" {
  name = "az104-lbrule"
  loadbalancer_id = azurerm_lb.lb.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "az104-fe"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.az104_be.id ]
  probe_id = azurerm_lb_probe.az104_hp.id
  idle_timeout_in_minutes = 4
}

resource "azurerm_public_ip" "az104_gwpip" {
  name                = "az104-gwpip"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "subnet_appgw" {
  name = "subnet-appgw"
  resource_group_name = azurerm_resource_group.az104_rg6.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes = [ "10.60.3.224/27" ]
}

resource "azurerm_application_gateway" "az104_appgw" {
  name                = "az104-appgw"
  location            = azurerm_resource_group.az104_rg6.location
  resource_group_name = azurerm_resource_group.az104_rg6.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.az104_gwpip.id
  }

  backend_address_pool {
    name = "az104-appgwbe"
    ip_addresses = [
      azurerm_network_interface.vm1.private_ip_address,
      azurerm_network_interface.vm2.private_ip_address
    ]
  }

  backend_address_pool {
    name = "az104-imagebe"
    ip_addresses = [
 azurerm_network_interface.vm1.private_ip_address
    ]
  }

  backend_address_pool {
    name = "az104-videobe"
    ip_addresses = [
  azurerm_network_interface.vm2.private_ip_address
    ]
  }

  backend_http_settings {
    name                  = "az104-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "az104-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "path-map"
    default_backend_address_pool_name  = "az104-appgwbe"
    default_backend_http_settings_name = "az104-http"

    path_rule {
      name                       = "images"
      paths                      = ["/image/*"]
      backend_address_pool_name  = "az104-imagebe"
      backend_http_settings_name = "az104-http"
    }

    path_rule {
      name                       = "videos"
      paths                      = ["/video/*"]
      backend_address_pool_name  = "az104-videobe"
      backend_http_settings_name = "az104-http"
    }
  }

  request_routing_rule {
    name                       = "az104-gwrule"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "az104-listener"
    url_path_map_name          = "path-map"
    priority                   = 10
  }

  depends_on = [
    azurerm_virtual_machine_extension.iis_vm1,
    azurerm_virtual_machine_extension.iis_vm2
  ]
}