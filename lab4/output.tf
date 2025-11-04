output "resource_group" {
  value = {
    name = azurerm_resource_group.az104_rg4.name
    location = azurerm_resource_group.az104_rg4.location
  }
}

output "virtual_networks" {
  value = {
    core_services_vnet = {
      name = azurerm_virtual_network.core_service.name
      address_space = azurerm_virtual_network.core_service.address_space
    }
    manufacturing_vnet = {
      name = azurerm_virtual_network.manufacturing_service.name
      address_space = azurerm_virtual_network.manufacturing_service.address_space
    }
  }
}

output "subnets" {
  value = {
    shared_services_subnet = azurerm_subnet.shared_service.address_prefixes
    database_subnet = azurerm_subnet.db.address_prefixes
    sensor_subnet1 = azurerm_subnet.sensor1.address_prefixes
    sensor_subnet2 = azurerm_subnet.sensor2.address_prefixes
  }
}

output "security_groups" {
  value = {
    application_security_group = azurerm_application_security_group.asg_web.name
    network_security_group = azurerm_network_security_group.nsg.name
    inbound_rule = azurerm_network_security_rule.allow_asg_traffic.name
    outbound_rule = azurerm_network_security_rule.deny_internet_access.name
  }
}

output "dns_zones" {
  value = {
    public_zone = azurerm_dns_zone.public.name
    private_zone = azurerm_private_dns_zone.private.name
  }
}

output "dns_records" {
  value = {
    public_a_record = "${azurerm_dns_a_record.www.name}.${azurerm_dns_zone.public.name}"
    private_a_record = "${azurerm_private_dns_a_record.sensorvm.name}.${azurerm_private_dns_zone.private.name}"
  }
}

output "network_links" {
  value = {
    link_name = azurerm_private_dns_zone_virtual_network_link.manufacturing_link.name
    linked_vnet_id = azurerm_private_dns_zone_virtual_network_link.manufacturing_link.virtual_network_id
  }
}
