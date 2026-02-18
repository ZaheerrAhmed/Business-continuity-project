# ============================================
# Infrastructure Outputs
# ============================================

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.aks_primary.name
}

output "resource_group_location" {
  description = "Resource group location"
  value       = azurerm_resource_group.aks_primary.location
}

# ============================================
# AKS Outputs
# ============================================

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks_primary.name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks_primary.id
}

output "aks_cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks_primary.fqdn
}

output "aks_node_resource_group" {
  description = "AKS node resource group"
  value       = azurerm_kubernetes_cluster.aks_primary.node_resource_group
}

output "get_kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_primary.name} --name ${azurerm_kubernetes_cluster.aks_primary.name}"
}

# ============================================
# PostgreSQL Outputs
# ============================================

output "postgres_primary_fqdn" {
  description = "PostgreSQL primary server FQDN"
  value       = azurerm_postgresql_flexible_server.primary.fqdn
}

output "postgres_primary_id" {
  description = "PostgreSQL primary server ID"
  value       = azurerm_postgresql_flexible_server.primary.id
}

output "postgres_dr_fqdn" {
  description = "PostgreSQL DR replica FQDN"
  value       = azurerm_postgresql_flexible_server.dr_replica.fqdn
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string (password not included)"
  value       = "postgresql://${var.postgres_admin_username}@${azurerm_postgresql_flexible_server.primary.fqdn}:5432/voting_db"
  sensitive   = false
}

# ============================================
# Storage Outputs
# ============================================

output "storage_account_primary_name" {
  description = "Primary storage account name"
  value       = azurerm_storage_account.azure_primary.name
}

output "storage_account_primary_id" {
  description = "Primary storage account ID"
  value       = azurerm_storage_account.azure_primary.id
}

output "storage_account_velero_name" {
  description = "Velero storage account name"
  value       = azurerm_storage_account.velero.name
}

output "storage_account_velero_id" {
  description = "Velero storage account ID"
  value       = azurerm_storage_account.velero.id
}

output "velero_storage_account_primary_blob_endpoint" {
  description = "Velero storage primary blob endpoint"
  value       = azurerm_storage_account.velero.primary_blob_endpoint
}

# ============================================
# Network Outputs
# ============================================

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_address_space" {
  description = "Virtual network address space"
  value       = azurerm_virtual_network.vnet.address_space
}

# ============================================
# Deployment Info
# ============================================

output "deployment_environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = var.subscription_id
}

