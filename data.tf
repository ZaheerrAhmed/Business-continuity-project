# ============================================
# Data Sources for Secrets from Azure Key Vault
# ============================================

# Reference to existing Key Vault
data "azurerm_key_vault" "terraform_kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

# Get PostgreSQL admin password from Key Vault
data "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  key_vault_id = data.azurerm_key_vault.terraform_kv.id
}

# ============================================
# Current Azure Subscription
# ============================================

data "azurerm_client_config" "current" {}
