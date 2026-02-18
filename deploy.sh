#!/bin/bash

# ============================================
# 🚀 One-Click Infrastructure Deployment Script
# ============================================

set -e  # Exit on any error

echo "════════════════════════════════════════"
echo "🚀 Infrastructure Deployment Starting..."
echo "════════════════════════════════════════"
echo ""

# ============================================
# Configuration
# ============================================

ENVIRONMENT="${1:-primary}"
SUBSCRIPTION_ID="704a6e87-98bd-489c-8e67-1317c8bfc787"
KEY_VAULT_NAME="zaheer-kv-57514"
STATE_STORAGE_NAME="tfstate770661260"
MGMT_RG="terraform-mgmt-rg"
LOCATION="eastus"

echo "📋 Configuration:"
echo "  Environment:    $ENVIRONMENT"
echo "  Subscription:   $SUBSCRIPTION_ID"
echo "  Key Vault:      $KEY_VAULT_NAME"
echo "  State Storage:  $STATE_STORAGE_NAME"
echo ""

# ============================================
# Step 1: Prerequisites Check
# ============================================

echo "🔍 [1/7] Checking prerequisites..."

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not installed!"
    echo "   Install: https://aka.ms/InstallAzureCLI"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not installed!"
    echo "   Install: https://www.terraform.io/downloads"
    exit 1
fi

echo "   ✅ Azure CLI: $(az version --query '"azure-cli"' -o tsv)"
echo "   ✅ Terraform: $(terraform version -json | jq -r .terraform_version)"
echo ""

# ============================================
# Step 2: Azure Login & Subscription
# ============================================

echo "🔐 [2/7] Checking Azure authentication..."

# Check if logged in
if ! az account show &> /dev/null; then
    echo "   Logging in to Azure..."
    az login
fi

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID"
CURRENT_SUB=$(az account show --query name -o tsv)
echo "   ✅ Using subscription: $CURRENT_SUB"
echo ""

# ============================================
# Step 3: Setup Management Resources
# ============================================

echo "🏗️  [3/7] Setting up management resources..."

# Create management resource group
if ! az group show --name "$MGMT_RG" &> /dev/null; then
    echo "   Creating management resource group..."
    az group create --name "$MGMT_RG" --location "$LOCATION" --output none
    echo "   ✅ Created: $MGMT_RG"
else
    echo "   ✅ Exists: $MGMT_RG"
fi

# Create storage account for Terraform state
if ! az storage account show --name "$STATE_STORAGE_NAME" --resource-group "$MGMT_RG" &> /dev/null; then
    echo "   Creating state storage account..."
    az storage account create \
      --name "$STATE_STORAGE_NAME" \
      --resource-group "$MGMT_RG" \
      --location "$LOCATION" \
      --sku "Standard_LRS" \
      --encryption-services blob \
      --output none
    echo "   ✅ Created: $STATE_STORAGE_NAME"
else
    echo "   ✅ Exists: $STATE_STORAGE_NAME"
fi

# Create container for state
if ! az storage container show --name "tfstate" --account-name "$STATE_STORAGE_NAME" &> /dev/null 2>&1; then
    echo "   Creating state container..."
    az storage container create \
      --name "tfstate" \
      --account-name "$STATE_STORAGE_NAME" \
      --output none
    echo "   ✅ Created: tfstate container"
else
    echo "   ✅ Exists: tfstate container"
fi

# Create Key Vault for secrets
if ! az keyvault show --name "$KEY_VAULT_NAME" &> /dev/null; then
    echo "   Creating Key Vault..."
    az keyvault create \
      --name "$KEY_VAULT_NAME" \
      --resource-group "$MGMT_RG" \
      --location "$LOCATION" \
      --enable-rbac-authorization false \
      --output none
    echo "   ✅ Created: $KEY_VAULT_NAME"
    
    # Generate and store PostgreSQL password
    echo "   Generating secure PostgreSQL password..."
    POSTGRES_PASSWORD=$(openssl rand -base64 32)
    az keyvault secret set \
      --vault-name "$KEY_VAULT_NAME" \
      --name "postgres-admin-password" \
      --value "$POSTGRES_PASSWORD" \
      --output none
    echo "   ✅ Password stored in Key Vault"
else
    echo "   ✅ Exists: $KEY_VAULT_NAME"
fi

echo ""

# ============================================
# Step 4: Terraform Init
# ============================================

echo "📦 [4/7] Initializing Terraform..."

terraform init -upgrade

echo "   ✅ Terraform initialized"
echo ""

# ============================================
# Step 5: Terraform Validate
# ============================================

echo "🔍 [5/7] Validating Terraform configuration..."

if terraform validate; then
    echo "   ✅ Configuration is valid"
else
    echo "   ❌ Configuration validation failed!"
    exit 1
fi

echo ""

# ============================================
# Step 6: Terraform Plan
# ============================================

echo "📋 [6/7] Planning infrastructure changes..."

terraform plan \
  -var="environment=$ENVIRONMENT" \
  -out=tfplan

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏸️  REVIEW THE PLAN ABOVE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Press ENTER to continue with deployment"
echo "Press Ctrl+C to cancel"
read -r

# ============================================
# Step 7: Terraform Apply
# ============================================

echo ""
echo "🚀 [7/7] Deploying infrastructure..."

terraform apply tfplan

echo ""
echo "════════════════════════════════════════"
echo "✅ Deployment Complete!"
echo "════════════════════════════════════════"
echo ""

# ============================================
# Post-Deployment Steps
# ============================================

echo "🔧 Post-deployment configuration..."

# Get outputs
CLUSTER_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "")
RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "")

if [ -n "$CLUSTER_NAME" ] && [ -n "$RG_NAME" ]; then
    echo ""
    echo "📥 Getting AKS credentials..."
    az aks get-credentials \
      --resource-group "$RG_NAME" \
      --name "$CLUSTER_NAME" \
      --overwrite-existing
    echo "   ✅ Kubeconfig updated"
    
    echo ""
    echo "🔍 Cluster status:"
    kubectl get nodes 2>/dev/null || echo "   (kubectl not configured yet)"
fi

# ============================================
# Summary & Next Steps
# ============================================

echo ""
echo "════════════════════════════════════════"
echo "📊 Deployment Summary"
echo "════════════════════════════════════════"
echo ""
echo "Environment:      $ENVIRONMENT"
echo "Resource Group:   $RG_NAME"
echo "AKS Cluster:      $CLUSTER_NAME"
echo ""
echo "🔗 Useful Commands:"
echo ""
echo "  View all outputs:"
echo "    terraform output"
echo ""
echo "  Get kubeconfig:"
echo "    $(terraform output -raw get_kubeconfig_command 2>/dev/null || echo 'az aks get-credentials --resource-group <rg> --name <cluster>')"
echo ""
echo "  Check cluster:"
echo "    kubectl get nodes"
echo "    kubectl get pods --all-namespaces"
echo ""
echo "  Update infrastructure:"
echo "    terraform plan"
echo "    terraform apply"
echo ""
echo "  Destroy infrastructure:"
echo "    ./destroy.sh $ENVIRONMENT"
echo ""
echo "════════════════════════════════════════"
echo "🎉 All Done! Infrastructure is Ready!"
echo "════════════════════════════════════════"
echo ""

