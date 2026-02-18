# ============================================
# General Configuration
# ============================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "704a6e87-98bd-489c-8e67-1317c8bfc787"
}

variable "environment" {
  description = "Environment name (primary, dr, dev)"
  type        = string
  default     = "primary"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "voting-app"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "Primary"
    ManagedBy   = "Terraform"
    Project     = "DisasterRecovery"
    Owner       = "Zaheer Ahmed"
  }
}

# ============================================
# Resource Group Configuration
# ============================================

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "aks-primary_group"
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = "eastus"
}

variable "postgres_location" {
  description = "PostgreSQL Azure region"
  type        = string
  default     = "westus"
}

variable "storage_location" {
  description = "Storage account location (for azure_primary storage)"
  type        = string
  default     = "centralus"
}

# ============================================
# AKS Configuration
# ============================================

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-primary"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "aks-primary-dns"
}

variable "aks_node_pool_name" {
  description = "Default node pool name"
  type        = string
  default     = "aksprimary"
}

variable "aks_node_count" {
  description = "Number of nodes in default pool"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DC2ads_v5"
}

variable "aks_vnet_subnet_id" {
  description = "Subnet ID for AKS"
  type        = string
  default     = "/subscriptions/704a6e87-98bd-489c-8e67-1317c8bfc787/resourceGroups/DefaultResourceGroup-EUS/providers/Microsoft.Network/virtualNetworks/vnet-primary/subnets/aks-subnet"
}

# ============================================
# PostgreSQL Configuration
# ============================================

variable "postgres_server_name_primary" {
  description = "PostgreSQL primary server name"
  type        = string
  default     = "postgresqlprimary"
}

variable "postgres_server_name_dr" {
  description = "PostgreSQL DR replica server name"
  type        = string
  default     = "postgresql-dr-replica"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "postgres_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "zaheeradmin"
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password (will be retrieved from Key Vault)"
  type        = string
  sensitive   = true
  default     = ""  # Will be overridden by Key Vault
}

variable "postgres_sku_name" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

variable "postgres_zone" {
  description = "PostgreSQL availability zone"
  type        = string
  default     = "1"
}

# ============================================
# Storage Account Configuration
# ============================================

variable "storage_account_name_primary" {
  description = "Primary storage account name"
  type        = string
  default     = "azureprimarystorage"
}

variable "storage_account_name_velero" {
  description = "Velero backup storage account name"
  type        = string
  default     = "velerobackupforprimary"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "RAGRS"
}

variable "storage_account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "storage_access_tier" {
  description = "Storage access tier"
  type        = string
  default     = "Hot"
}

# ============================================
# Virtual Network Configuration
# ============================================

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "vnet-primary"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# ============================================
# Key Vault Configuration (for secrets)
# ============================================

variable "key_vault_name" {
  description = "Key Vault name for storing secrets"
  type        = string
  default     = "zaheer-kv-57514"
}

variable "key_vault_resource_group" {
  description = "Resource group where Key Vault is located"
  type        = string
  default     = "terraform-mgmt-rg"
}

# ============================================
# Remote State Configuration
# ============================================

variable "state_storage_account_name" {
  description = "Storage account name for Terraform state"
  type        = string
  default     = "tfstate770661260"
}

variable "state_resource_group_name" {
  description = "Resource group for Terraform state storage"
  type        = string
  default     = "terraform-mgmt-rg"
}

variable "state_container_name" {
  description = "Container name for Terraform state"
  type        = string
  default     = "tfstate"
}

