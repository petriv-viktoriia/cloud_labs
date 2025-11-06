output "resource_group_name" {
  value = azurerm_resource_group.az104_rg7.name
}

output "storage_account" {
  value = {
    name = azurerm_storage_account.stg_account.name
    primary_location = azurerm_storage_account.stg_account.primary_location
    secondary_location = azurerm_storage_account.stg_account.secondary_location
    primary_blob_endpoint = azurerm_storage_account.stg_account.primary_blob_endpoint
    primary_file_endpoint = azurerm_storage_account.stg_account.primary_file_endpoint
  }
}

output "blob_container" {
  value = {
    name = azurerm_storage_container.data.name
    url = "https://${azurerm_storage_account.stg_account.name}.blob.core.windows.net/${azurerm_storage_container.data.name}"
  }
}

output "file_share" {
  value = {
    name = azurerm_storage_share.share1.name
    url = "https://${azurerm_storage_account.stg_account.name}.file.core.windows.net/${azurerm_storage_share.share1.name}"
  }
}

output "sas_token" {
  value     = data.azurerm_storage_account_sas.sas.sas
  sensitive = true
}
