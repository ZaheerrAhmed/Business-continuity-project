# ============================================
# Resource Group
# ============================================

resource "azurerm_resource_group" "aks_primary" {
  name     = var.resource_group_name
  location = var.primary_location
  tags     = var.tags
}

# ============================================
# AKS Cluster
# ============================================

resource "azurerm_kubernetes_cluster" "aks_primary" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_primary.location
  resource_group_name = azurerm_resource_group.aks_primary.name
  dns_prefix          = var.aks_dns_prefix
  tags                = var.tags

  default_node_pool {
    name           = var.aks_node_pool_name
    vm_size        = var.aks_vm_size
    node_count     = var.aks_node_count
    vnet_subnet_id = var.aks_vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      # API server settings
      api_server_access_profile,
      # Image management
      image_cleaner_enabled,
      image_cleaner_interval_hours,
      # Identity & security
      oidc_issuer_enabled,
      workload_identity_enabled,
      azure_policy_enabled,
      automatic_channel_upgrade,
      # Node pool settings
      default_node_pool[0].zones,
      default_node_pool[0].enable_auto_scaling,
      default_node_pool[0].max_count,
      default_node_pool[0].min_count,
      default_node_pool[0].upgrade_settings,
      # Maintenance
      maintenance_window_auto_upgrade,
      maintenance_window_node_os,
      # Network
      network_profile,
      # Tags (if you want to manage tags outside Terraform)
      tags
    ]
  }
}

# ============================================
# PostgreSQL Primary Server
# ============================================

resource "azurerm_postgresql_flexible_server" "primary" {
  name                   = var.postgres_server_name_primary
  resource_group_name    = azurerm_resource_group.aks_primary.name
  location               = var.postgres_location
  version                = var.postgres_version
  administrator_login    = var.postgres_admin_username
  administrator_password = data.azurerm_key_vault_secret.postgres_admin_password.value  # ✅ SECURE!
  storage_mb             = var.postgres_storage_mb
  sku_name               = var.postgres_sku_name
  zone                   = var.postgres_zone
  tags                   = var.tags

  lifecycle {
    ignore_changes = [
      version,
      administrator_password,  # Don't update password on every apply
      sku_name,
      zone,
      tags
    ]
  }
}

# ============================================
# PostgreSQL DR Replica
# ============================================

resource "azurerm_postgresql_flexible_server" "dr_replica" {
  name                   = var.postgres_server_name_dr
  resource_group_name    = azurerm_resource_group.aks_primary.name
  location               = var.postgres_location
  version                = var.postgres_version
  administrator_login    = var.postgres_admin_username
  administrator_password = data.azurerm_key_vault_secret.postgres_admin_password.value  # ✅ SECURE!
  storage_mb             = var.postgres_storage_mb
  sku_name               = var.postgres_sku_name
  zone                   = var.postgres_zone
  tags                   = var.tags

  lifecycle {
    ignore_changes = [
      version,
      administrator_password,
      sku_name,
      zone,
      tags
    ]
  }
}

# ============================================
# Storage Account - Primary (Cloud Shell Storage)
# ============================================

resource "azurerm_storage_account" "azure_primary" {
  name                             = var.storage_account_name_primary
  resource_group_name              = azurerm_resource_group.aks_primary.name
  location                         = var.storage_location
  account_tier                     = var.storage_account_tier
  account_replication_type         = var.storage_replication_type
  account_kind                     = var.storage_account_kind
  access_tier                      = var.storage_access_tier
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  
  tags = merge(var.tags, {
    "ms-resource-usage" = "azure-cloud-shell"
  })
}

# ============================================
# Storage Account - Velero Backups
# ============================================

resource "azurerm_storage_account" "velero" {
  name                             = var.storage_account_name_velero
  resource_group_name              = azurerm_resource_group.aks_primary.name
  location                         = var.primary_location
  account_tier                     = var.storage_account_tier
  account_replication_type         = var.storage_replication_type
  account_kind                     = var.storage_account_kind
  access_tier                      = var.storage_access_tier
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  tags                             = var.tags
}

# ============================================
# Virtual Network
# ============================================

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.aks_primary.name
  location            = var.primary_location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

