#!/bin/bash

# SET YOUR REAL SUBSCRIPTION ID HERE!
SUBSCRIPTION_ID="704a6e87-98bd-489c-8e67-1317c8bfc787"

echo "Importing resources using subscription: $SUBSCRIPTION_ID"

terraform import azurerm_resource_group.aks_primary \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group

terraform import azurerm_kubernetes_cluster.aks_primary \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.ContainerService/managedClusters/aks-primary

terraform import azurerm_postgresql_flexible_server.primary \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.DBforPostgreSQL/flexibleServers/postgresqlprimary

terraform import azurerm_postgresql_flexible_server.dr_replica \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.DBforPostgreSQL/flexibleServers/postgresql-dr-replica

terraform import azurerm_storage_account.azure_primary \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.Storage/storageAccounts/azureprimarystorage

terraform import azurerm_storage_account.velero \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.Storage/storageAccounts/velerobackupforprimary

terraform import azurerm_virtual_network.vnet \
  /subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-primary_group/providers/Microsoft.Network/virtualNetworks/vnet-primary

echo "Import complete! Run 'terraform show' to see imported configuration."

