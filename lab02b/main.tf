data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "az104_rg2" {
  name = "az104-rg2"
  location = var.location

  tags = {
    "Cost Center" = "000"
  }
}

# resource "azurerm_resource_group_policy_assignment" "require_tag" {
#   name = "cost-center-require-tag"
#   display_name = "Require Cost Center tag and its value on resources"
#   description = "Require Cost Center tag and its value on all resources in the resource group"
#   resource_group_id = azurerm_resource_group.az104_rg2.id
#   enforce = true
#   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
#   parameters = jsonencode({
#     tagName = {
#       value = "Cost Center"
#     }
#     tagValue = {
#       value = "000"
#     }
#   })
# }

resource "azurerm_resource_group_policy_assignment" "inherit_tag" {
  name = "cost-center-inherit-tag"
  display_name = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  description = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  resource_group_id = azurerm_resource_group.az104_rg2.id
  enforce = true
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
  location = azurerm_resource_group.az104_rg2.location
  identity {
    type = "SystemAssigned"
  }
  parameters = jsonencode({
    tagName = {
      value = "Cost Center"
    }
  })
}

resource "azurerm_resource_group_policy_remediation" "remediate_tags" {
  name = "cost-center-remediate-tags"
  resource_group_id = azurerm_resource_group.az104_rg2.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.inherit_tag.id

  depends_on = [
    azurerm_resource_group_policy_assignment.inherit_tag
  ]
}

resource "random_string" "str" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "test" {
  name = "az104test${random_string.str.result}"
  resource_group_name = azurerm_resource_group.az104_rg2.name
  location = azurerm_resource_group.az104_rg2.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    azurerm_resource_group_policy_assignment.inherit_tag
  ]
}

resource "azurerm_management_lock" "rg_lock" {
  name = "rg-lock"
  scope = azurerm_resource_group.az104_rg2.id
  lock_level = "CanNotDelete"
  notes = "Lock to prevent deletion"
}