# ============================================
# Terraform Backend Configuration
# Store state in Azure Storage Account
# ============================================

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-mgmt-rg"
    storage_account_name = "tfstate770661260"
    container_name       = "tfstate"
    key                  = "primary.terraform.tfstate"
    
    # These will be set via environment variables or command line
    # subscription_id = "704a6e87-98bd-489c-8e67-1317c8bfc787"
    # tenant_id       = "YOUR_TENANT_ID"
  }
}

# Note: Before using this backend, you need to:
# 1. Create the storage account: az storage account create --name tfstate770661260 --resource-group terraform-mgmt-rg
# 2. Create the container: az storage container create --name tfstate --account-name tfstate770661260
# 3. Run: terraform init -migrate-state

