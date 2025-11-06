resource "azurerm_resource_group" "az104_rg7" {
  name = "az104-rg7"
  location = var.location
}

resource "random_string" "storage" {
  length = 8
  special = false
  upper = false
}


resource "azurerm_storage_account" "stg_account" {
  name = "az104stg${random_string.storage.result}"
  resource_group_name = azurerm_resource_group.az104_rg7.name
  location = azurerm_resource_group.az104_rg7.location
  account_tier = "Standard"
  account_replication_type = "GRS"
  public_network_access_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Allow"
    bypass = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }
}

resource "azurerm_storage_management_policy" "life_manage_rule" {
  storage_account_id = azurerm_storage_account.stg_account.id
  rule {
    name = "Movetocool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}


resource "azurerm_storage_container" "data" {
  name = "data"
  storage_account_id = azurerm_storage_account.stg_account.id
  container_access_type = "private"
}

resource "azurerm_storage_container_immutability_policy" "data_policy" {
  storage_container_resource_manager_id = azurerm_storage_container.data.resource_manager_id
  immutability_period_in_days = 180
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.stg_account.primary_connection_string
  https_only = true
  start  = timeadd(timestamp(), "-24h")
  expiry = timeadd(timestamp(), "24h")
  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    file  = false
    queue = false
    table = false
  }



  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    filter = false
    tag = false
  }
}

resource "azurerm_storage_share" "share1" {
  name = "share1"
  storage_account_id = azurerm_storage_account.stg_account.id
  quota = 50
  access_tier = "TransactionOptimized"
}

resource "azurerm_virtual_network" "vnet1" {
  name = "vnet1"
  location = azurerm_resource_group.az104_rg7.location
  resource_group_name = azurerm_resource_group.az104_rg7.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name = "subnet"
  virtual_network_name = azurerm_virtual_network.vnet1.name
  resource_group_name = azurerm_resource_group.az104_rg7.name
  address_prefixes = ["10.0.1.0/24"]
  service_endpoints = [ "Microsoft.Storage" ]
}
