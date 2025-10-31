output "mg_information" {
  value = {
    id = azurerm_management_group.az104_mg1.id
    name = azurerm_management_group.az104_mg1.name
  }
}

output "helpdesk_info" {
  value = {
    object_id = azuread_group.helpdesk.object_id
    display_name = azuread_group.helpdesk.display_name
  }
}

output "role_assignments" {
  value = {
    vm_contributor = {
      role        = "Virtual Machine Contributor"
      scope       = "Management Group: ${azurerm_management_group.az104_mg1.name}"
      principal   = azuread_group.helpdesk.display_name
      description = azurerm_role_assignment.vm_contributor.description
    }
  }
}

output "custom_role_definition" {
  description = "Деталі кастомної ролі"
  value = {
    name        = azurerm_role_definition.custom_support_req.name
    description = azurerm_role_definition.custom_support_req.description
    actions     = azurerm_role_definition.custom_support_req.permissions[0].actions
    not_actions = azurerm_role_definition.custom_support_req.permissions[0].not_actions
    scope       = azurerm_role_definition.custom_support_req.assignable_scopes
  }
}