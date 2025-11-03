resource "azurerm_resource_group" "az104_rg3" {
  name = "az104-rg3"
  location = var.location
}

# resource "azurerm_managed_disk" "az104_disk1" {
#   name = "az104-disk1"
#   location = azurerm_resource_group.az104_rg3.location
#   resource_group_name = azurerm_resource_group.az104_rg3.name
#   storage_account_type = "Standard_LRS"
#   create_option = "Empty"
#   disk_size_gb = 32
# }

locals {
  disks = {
    disk1 = {
        size = 32
        sat = "Standard_LRS"
    }
    disk2 = {
        size = 32
        sat = "Standard_LRS"
    }
    disk3 = {
        size = 32
        sat = "Standard_LRS"
    }
    disk4 = {
        size = 32
        sat = "Standard_LRS"
    }
    disk5 = {
        size = 32
        sat = "StandardSSD_LRS"
    }
  }
}


resource "azurerm_managed_disk" "disks" {
  for_each = local.disks
  name = "az104-${each.key}"
  location = azurerm_resource_group.az104_rg3.location
  resource_group_name = azurerm_resource_group.az104_rg3.name
  storage_account_type = each.value.sat
  create_option = "Empty"
  disk_size_gb = each.value.size
}
