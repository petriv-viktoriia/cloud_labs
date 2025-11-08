resource "azurerm_resource_group" "az104_rg9" {
  name = "az104-rg9"
  location = var.location
}

resource "azurerm_service_plan" "plan" {
  name = "az104-service-plan"
  location = azurerm_resource_group.az104_rg9.location
  resource_group_name = azurerm_resource_group.az104_rg9.name
  os_type = "Linux"
  sku_name = "S1"
}

resource "azurerm_linux_web_app" "web_app_rg9" {
  name = "az104-rg9-web-app"
  location = azurerm_resource_group.az104_rg9.location
  resource_group_name = azurerm_resource_group.az104_rg9.name
  service_plan_id = azurerm_service_plan.plan.id
  site_config {
    application_stack {
      php_version = "8.2"
    }
  }
}

resource "azurerm_linux_web_app_slot" "staging_slot" {
  name = "staging"
  app_service_id = azurerm_linux_web_app.web_app_rg9.id
  site_config {
    application_stack {
      php_version = "8.2"
    }
  }
}

resource "azurerm_app_service_source_control_slot" "staging" {
  slot_id = azurerm_linux_web_app_slot.staging_slot.id
  repo_url = "https://github.com/Azure-Samples/php-docs-hello-world"
  branch = "master"
  use_manual_integration = true
}



resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-webapp"
  location            = azurerm_resource_group.az104_rg9.location
  resource_group_name = azurerm_resource_group.az104_rg9.name
  target_resource_id  = azurerm_service_plan.plan.id
  enabled             = true

  profile {
    name = "DefaultProfile"
    capacity {
      minimum = "1"
      maximum = "2"
      default = "1"
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
