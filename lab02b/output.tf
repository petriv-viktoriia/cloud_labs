output "resource_group" {
  value = {
    id = azurerm_resource_group.az104_rg2.id
    name = azurerm_resource_group.az104_rg2.name
    location = azurerm_resource_group.az104_rg2.location
    tags = azurerm_resource_group.az104_rg2.tags
  }
}

output "policy_assignments" {
  value = {
    id           = azurerm_resource_group_policy_assignment.inherit_tag.id
    name         = azurerm_resource_group_policy_assignment.inherit_tag.name
    display_name = azurerm_resource_group_policy_assignment.inherit_tag.display_name
    scope        = azurerm_resource_group_policy_assignment.inherit_tag.resource_group_id
    enforce      = azurerm_resource_group_policy_assignment.inherit_tag.enforce
  }
}

output "storage_account" {
  value = {
    name = azurerm_storage_account.test.name
    tags = azurerm_storage_account.test.tags
  }
}

output "rg_lock" {
  value = {
    id = azurerm_management_lock.rg_lock.id
    lock_level = azurerm_management_lock.rg_lock.lock_level
  }
}