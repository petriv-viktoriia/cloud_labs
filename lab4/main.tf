resource "azurerm_resource_group" "az104_rg4" {
  name = "az104-rg4"
  location = var.location
}

resource "azurerm_virtual_network" "core_service" {
  name = "CoreServicesVnet"
  location = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_space = [ "10.20.0.0/16" ]
}

resource "azurerm_subnet" "shared_service" {
  name = "SharedServicesSubnet"
  virtual_network_name = azurerm_virtual_network.core_service.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_prefixes = [ "10.20.10.0/24" ]
}

resource "azurerm_subnet" "db" {
  name = "DatabaseSubnet"
  virtual_network_name = azurerm_virtual_network.core_service.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_prefixes = [ "10.20.20.0/24" ]
}

resource "azurerm_virtual_network" "manufacturing_service" {
  name = "ManufacturingVnet"
  location = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_space = [ "10.30.0.0/16" ]
}

resource "azurerm_subnet" "sensor1" {
  name = "SensorSubnet1"
  virtual_network_name = azurerm_virtual_network.manufacturing_service.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_prefixes = [ "10.30.10.0/24" ]
}

resource "azurerm_subnet" "sensor2" {
  name = "SensorSubnet2"
  virtual_network_name = azurerm_virtual_network.manufacturing_service.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_prefixes = [ "10.30.21.0/24" ]
}

resource "azurerm_application_security_group" "asg_web" {
  name = "asg-web"
  resource_group_name = azurerm_resource_group.az104_rg4.name
  location = azurerm_resource_group.az104_rg4.location
}

resource "azurerm_network_security_group" "nsg" {
  name = "myNSGSecure"
  resource_group_name = azurerm_resource_group.az104_rg4.name
  location = azurerm_resource_group.az104_rg4.location
}

resource "azurerm_network_security_rule" "allow_asg_traffic" {
  name = "AllowASG"
  priority = 100
  protocol = "Tcp"
  resource_group_name = azurerm_resource_group.az104_rg4.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  direction = "Inbound"
  access = "Allow"
  source_port_range = "*"
  source_application_security_group_ids = [ azurerm_application_security_group.asg_web.id ]
  destination_port_ranges = [ "80", "443" ]
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "deny_internet_access" {
  name = "DenyInternetOutbound"
  priority = 4096
  access = "Deny"
  protocol = "*"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "*"
  destination_address_prefix = "Internet"
  resource_group_name = azurerm_resource_group.az104_rg4.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  direction = "Outbound"
}

resource "azurerm_subnet_network_security_group_association" "associate_core_services" {
  subnet_id = azurerm_subnet.shared_service.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_dns_zone" "public" {
  name = "contoso-viktoriia.com"
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_dns_a_record" "www" {
  name = "www"
  records = [ "10.1.1.4" ]
  zone_name = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  ttl = 3600
}

resource "azurerm_private_dns_zone" "private" {
  name = "private.contoso.com"
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "manufacturing_link" {
  name = "manufacturing-link"
  virtual_network_id = azurerm_virtual_network.manufacturing_service.id
  resource_group_name = azurerm_resource_group.az104_rg4.name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
}

resource "azurerm_private_dns_a_record" "sensorvm" {
  name = "sensorvm"
  records = [ "10.1.1.4" ]
  zone_name = azurerm_private_dns_zone.private.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  ttl = 3600
}