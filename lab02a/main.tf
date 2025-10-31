data "azurerm_subscription" "current" {}

resource "azurerm_management_group" "az104_mg1" {
  name = "az104-mg1"
  display_name = "az104-mg1"
}

resource "azurerm_management_group_subscription_association" "az104_mg1_sub" {
  management_group_id = azurerm_management_group.az104_mg1.id
  subscription_id = data.azurerm_subscription.current.id
}

resource "azuread_group" "helpdesk" {
  description = "Help Desk Group"
  display_name = "helpdesk"
  security_enabled = true
}

resource "azurerm_role_assignment" "vm_contributor" {
  description = "Connect Virtual Machine Contributor to Helpdesk"
  scope = azurerm_management_group.az104_mg1.id
  principal_id = azuread_group.helpdesk.object_id
  role_definition_name = "Virtual Machine Contributor"

  depends_on = [ 
    azurerm_management_group.az104_mg1,
    azuread_group.helpdesk 
  ]
}

resource "azurerm_role_definition" "custom_support_req" {
  scope = azurerm_management_group.az104_mg1.id
  name = "Custom Support Request"
  description = "A custom contributor role for support requests."

  permissions {
    actions = [ 
      "Microsoft.Support/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]

    not_actions = [ 
        "Microsoft.Support/register/action"
    ]
  }

  assignable_scopes = [
    azurerm_management_group.az104_mg1.id
  ]
}