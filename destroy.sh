#!/bin/bash

# ============================================
# 🗑️  Complete Infrastructure Destroy Script
# ============================================

set -e

echo "════════════════════════════════════════"
echo "🗑️  Infrastructure Destruction"
echo "════════════════════════════════════════"
echo ""

ENVIRONMENT="${1:-primary}"
SUBSCRIPTION_ID="704a6e87-98bd-489c-8e67-1317c8bfc787"

echo "⚠️  WARNING: You are about to DESTROY all infrastructure!"
echo ""
echo "Environment:   $ENVIRONMENT"
echo "Subscription:  $SUBSCRIPTION_ID"
echo ""
echo "This action CANNOT be undone!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Type 'yes' to confirm destruction:"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "❌ Destruction cancelled"
    exit 0
fi

echo ""
echo "════════════════════════════════════════"
echo "🔥 Starting Destruction Process"
echo "════════════════════════════════════════"
echo ""

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID"

# Show what will be destroyed
echo "📋 Generating destruction plan..."
terraform plan -destroy -var="environment=$ENVIRONMENT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  FINAL CONFIRMATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Review the plan above."
echo "Type 'destroy' to proceed:"
read -r FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "destroy" ]; then
    echo ""
    echo "❌ Destruction cancelled"
    exit 0
fi

echo ""
echo "🔥 Destroying infrastructure..."

# Destroy infrastructure
terraform destroy -var="environment=$ENVIRONMENT" -auto-approve

echo ""
echo "════════════════════════════════════════"
echo "✅ Infrastructure Destroyed!"
echo "════════════════════════════════════════"
echo ""
echo "📝 What was destroyed:"
echo "  - Resource Group: aks-$ENVIRONMENT_group"
echo "  - AKS Cluster"
echo "  - PostgreSQL Servers"
echo "  - Storage Accounts"
echo "  - Virtual Network"
echo "  - All associated resources"
echo ""
echo "💡 To recreate the infrastructure:"
echo "   ./deploy.sh $ENVIRONMENT"
echo ""
echo "🔐 Secrets remain in Key Vault:"
echo "   Key Vault: zaheer-kv-57514"
echo "   Resource Group: terraform-mgmt-rg"
echo ""
echo "   To view stored password:"
echo "   az keyvault secret show --name postgres-admin-password --vault-name zaheer-kv-57514 --query value -o tsv"
echo ""

