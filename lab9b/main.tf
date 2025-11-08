resource "azurerm_resource_group" "az104_rg9" {
  name = "az104-rg9"
  location = var.location
}

resource "random_string" "str" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_container_group" "az104_c1" {
  name = "az104-c1"
  resource_group_name = azurerm_resource_group.az104_rg9.name
  location = azurerm_resource_group.az104_rg9.location
  os_type = "Linux"
  ip_address_type = "Public"
  dns_name_label = "az104-c1-${random_string.str.result}"

  container {
    name = "aci-helloworld"
    image = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu = 1
    memory = 1.5

    ports {
      port = 80
      protocol = "TCP"
    }
  }
}