output "resource_group" {
  description = "Resource Group info"
  value = {
    name     = azurerm_resource_group.az104_rg9.name
    location = azurerm_resource_group.az104_rg9.location
  }
}

output "app_service_plan" {
  description = "App Service Plan info"
  value = {
    name = azurerm_service_plan.plan.name
    sku  = azurerm_service_plan.plan.sku_name
  }
}

output "production_app" {
  description = "Production Web App info"
  value = {
    name         = azurerm_linux_web_app.web_app_rg9.name
    default_url  = "https://${azurerm_linux_web_app.web_app_rg9.default_hostname}"
    outbound_ips = azurerm_linux_web_app.web_app_rg9.outbound_ip_addresses
  }
}

output "staging_slot" {
  description = "Staging slot info"
  value = {
    name        = azurerm_linux_web_app_slot.staging_slot.name
    default_url = "https://${azurerm_linux_web_app_slot.staging_slot.default_hostname}"
  }
}

output "autoscale_settings" {
  description = "Autoscale configuration"
  value = {
    name            = azurerm_monitor_autoscale_setting.autoscale.name
    min_instances   = 1
    scale_out_cpu   = "70%"
    scale_in_cpu    = "25%"
  }
}
