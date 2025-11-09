resource "azurerm_resource_group" "az104_rg_region1" {
  name = "az104-rg-region1"
  location = var.loc1
}

resource "random_string" "str" {
  length = 8
  special = false
  upper = false
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.az104_rg_region1.location
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
}

resource "azurerm_subnet" "subnet" {
  name = "subnet"
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name = "pip"
  location = azurerm_resource_group.az104_rg_region1.location
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg"
  location = azurerm_resource_group.az104_rg_region1.location
  resource_group_name = azurerm_resource_group.az104_rg_region1.name

  security_rule {
    name = "Allow-HTTP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name = "nic"
  location = azurerm_resource_group.az104_rg_region1.location
  resource_group_name = azurerm_resource_group.az104_rg_region1.name

  ip_configuration {
    name = "nic_configuration"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name = "az104-10-vm0"
  admin_username = var.username
  admin_password = var.password
  location = azurerm_resource_group.az104_rg_region1.location
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_D2s_v3"

  os_disk {
    name = "myOsDisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
}

resource "azurerm_recovery_services_vault" "az104_rsv" {
  name = "az104-rsv-region1"
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  location = azurerm_resource_group.az104_rg_region1.location
  sku = "Standard"
  storage_mode_type = "GeoRedundant"
  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "az104_backup" {
  name = "az104-backup"
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv.name
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  backup {
    frequency = "Daily"
    time = "00:00"
  }
  retention_daily {
    count = 30
  }
  instant_restore_retention_days = 2
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv.name
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  source_vm_id = azurerm_windows_virtual_machine.vm.id
  backup_policy_id = azurerm_backup_policy_vm.az104_backup.id
}

resource "azurerm_storage_account" "sta" {
  name = "az104sta${random_string.str.result}"
  resource_group_name = azurerm_resource_group.az104_rg_region1.name
  location = azurerm_resource_group.az104_rg_region1.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_diagnostic_setting" "vault_diagnostic" {
  name = "Logs and Metrics to storage"
  target_resource_id = azurerm_recovery_services_vault.az104_rsv.id
  storage_account_id = azurerm_storage_account.sta.id

  enabled_log {
    category = "AzureSiteRecoveryJobs"
  }

  enabled_log {
    category = "AzureSiteRecoveryEvents"
  }

  enabled_log {
    category = "AzureBackupReport"
  }

  enabled_log {
    category = "AddonAzureBackupJobs"
  }

  enabled_log {
    category = "AddonAzureBackupAlerts"
  }

  enabled_log {
    category = "AzureSiteRecoveryJobs"
  }

  enabled_log {
    category = "AzureSiteRecoveryEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_resource_group" "az104_rg_region2" {
  name = "az104-rg-region2"
  location = var.loc2
}

resource "azurerm_recovery_services_vault" "az104_rsv2" {
  name = "az104-rsv-region2"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  location = azurerm_resource_group.az104_rg_region2.location
  sku = "Standard"
  storage_mode_type = "GeoRedundant"
  soft_delete_enabled = true

  depends_on = [azurerm_resource_group.az104_rg_region2]
}

resource "azurerm_virtual_network" "vnet_region2" {
  name = "vnet-region2"
  address_space = ["10.1.0.0/16"]
  location = azurerm_resource_group.az104_rg_region2.location
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
}

resource "azurerm_subnet" "subnet_region2" {
  name = "subnet-region2"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  virtual_network_name = azurerm_virtual_network.vnet_region2.name
  address_prefixes = ["10.1.1.0/24"]
}

resource "azurerm_site_recovery_fabric" "primary" {
  name = "primary-fabric"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  location = azurerm_resource_group.az104_rg_region1.location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name = "secondary-fabric"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  location = azurerm_resource_group.az104_rg_region2.location
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name = "primary-protection-container"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name = "secondary-protection-container"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  name = "replication-policy"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  recovery_point_retention_in_minutes = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "container_mapping" {
  name = "container-mapping"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id = azurerm_site_recovery_replication_policy.policy.id
}

resource "azurerm_site_recovery_network_mapping" "network_mapping" {
  name = "network-mapping"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
  source_network_id = azurerm_virtual_network.vnet.id
  target_network_id = azurerm_virtual_network.vnet_region2.id
}

resource "azurerm_site_recovery_replicated_vm" "vm_replication" {
  name = "vm-replication"
  resource_group_name = azurerm_resource_group.az104_rg_region2.name
  recovery_vault_name = azurerm_recovery_services_vault.az104_rsv2.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  source_vm_id = azurerm_windows_virtual_machine.vm.id
  recovery_replication_policy_id = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  target_resource_group_id = azurerm_resource_group.az104_rg_region2.id
  target_recovery_fabric_id = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id = azurerm_windows_virtual_machine.vm.os_disk[0].id
    staging_storage_account_id = azurerm_storage_account.sta.id
    target_resource_group_id = azurerm_resource_group.az104_rg_region2.id
    target_disk_type = "Standard_LRS"
    target_replica_disk_type = "Standard_LRS"
  }

  network_interface {
    source_network_interface_id = azurerm_network_interface.nic.id
    target_subnet_name = azurerm_subnet.subnet_region2.name
    recovery_public_ip_address_id = null
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container_mapping,
    azurerm_site_recovery_network_mapping.network_mapping
  ]
}
