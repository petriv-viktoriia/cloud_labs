resource "azurerm_resource_group" "az104_rg9" {
  name = "az104-rg9"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log_workspace" {
  name = "az104-rg9-log-workspace"
  location = azurerm_resource_group.az104_rg9.location
  resource_group_name = azurerm_resource_group.az104_rg9.name
  sku = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_container_app_environment" "container_env" {
  name = "my-environment"
  location = azurerm_resource_group.az104_rg9.location
  resource_group_name = azurerm_resource_group.az104_rg9.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
}

resource "azurerm_container_app" "my_app" {
  name = "my-app"
  container_app_environment_id = azurerm_container_app_environment.container_env.id
  resource_group_name = azurerm_resource_group.az104_rg9.name
  revision_mode = "Single"

  template {
    container {
      name = "my-app"
      image = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    target_port = 80
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }
}