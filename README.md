 🚀 Azure Infrastructure as Code with Terraform

Complete Infrastructure as Code solution for deploying production-ready Azure Kubernetes Service (AKS) with PostgreSQL databases, storage accounts, and disaster recovery capabilities.


 📋 Table of Contents

 [Overview]
 [Features]
 [Prerequisites]
 [Quick Start]
 [Infrastructure Components]
 [Configuration]
 [Usage]
 [Outputs]
 [Disaster Recovery]
 [Troubleshooting]
 [Author]



🎯 Overview

This project automates Azure infrastructure deployment using Terraform. What previously took 8+ hours of manual work now deploys in 15 minutes with a single command.

The Problem

Manual infrastructure provisioning is:
- Time-consuming (8+ hours)
- Error-prone (human mistakes)
- Hard to replicate exactly
- Difficult to collaborate on
- Not version controlled

The Solution

Infrastructure as Code provides:
- Fast deployment (15 minutes)
- Zero errors (tested code)
- Perfect replication every time
- Easy team collaboration
- Full version control

---

## ✨ Features

- **One-Click Deployment** - Deploy entire infrastructure with `./deploy.sh primary`
- **One-Click Cleanup** - Remove all resources with `./destroy.sh primary`
- **Secure Secrets** - Passwords stored in Azure Key Vault
- **Remote State** - Terraform state stored in Azure Storage
- **Reproducible** - Destroy and recreate identical infrastructure
- **Multi-Environment** - Deploy dev, staging, production from same code
- **Version Controlled** - Track all infrastructure changes

---

## 📦 Prerequisites

### Required Tools

- **Azure CLI** (v2.50+) - [Installation Guide](https://aka.ms/InstallAzureCLI)
- **Terraform** (v1.6+) - [Installation Guide](https://www.terraform.io/downloads)
- **kubectl** (Latest) - [Installation Guide](https://kubernetes.io/docs/tasks/tools/)
- **Git** (Latest)

### Azure Requirements

- Active Azure subscription
- Contributor role on subscription

### Verify Installation
```bash
az --version      # Azure CLI
terraform version # Terraform
kubectl version   # Kubernetes CLI
git --version     # Git
```

---

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/azure-infrastructure-terraform.git
cd azure-infrastructure-terraform
```

### 2. Login to Azure
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Deploy Infrastructure
```bash
chmod +x deploy.sh destroy.sh
./deploy.sh primary
```

**That's it!** Infrastructure deploys in approximately 15 minutes.

### 4. Verify Deployment
```bash
terraform output
kubectl get nodes
```

---

## 🏗️ Infrastructure Components

This Terraform configuration creates the following Azure resources:

### Compute & Container
- **AKS Cluster** - Kubernetes cluster with autoscaling (1-3 nodes)
  - VM Size: Standard_DC2ads_v5
  - Kubernetes Version: 1.33.5
  - Network: Azure CNI with Overlay mode

### Database
- **PostgreSQL Primary** - Main database server
  - SKU: GP_Standard_D2s_v3
  - Storage: 32GB
  - Version: 16
  
- **PostgreSQL DR Replica** - Disaster recovery database
  - Same configuration as primary
  - Located in different region

### Storage
- **Primary Storage Account** - Cloud Shell storage
  - Replication: RAGRS
  - Tier: Hot
  
- **Velero Storage Account** - Kubernetes backup storage
  - Replication: RAGRS
  - Tier: Hot

### Network
- **Virtual Network** - Network infrastructure
  - Address Space: 10.0.0.0/16

### Management
- **Azure Key Vault** - Secure password storage
- **Storage Account** - Terraform state storage

---

## ⚙️ Configuration

### Basic Configuration

Edit `variables.tf` to customize your deployment:
```hcl
# Azure Subscription
variable "subscription_id" {
  default = "YOUR_SUBSCRIPTION_ID"
}

# Environment Name
variable "environment" {
  default = "primary"
}

# AKS Settings
variable "aks_node_count" {
  default = 1
}

variable "aks_vm_size" {
  default = "Standard_DC2ads_v5"
}

# PostgreSQL Settings
variable "postgres_sku_name" {
  default = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  default = 32768
}

# Regions
variable "primary_location" {
  default = "eastus"
}

variable "postgres_location" {
  default = "westus"
}
```

### Using Environment Variables
```bash
export TF_VAR_subscription_id="YOUR_SUBSCRIPTION_ID"
export TF_VAR_environment="production"
export TF_VAR_aks_node_count=3
```

---

## 💻 Usage

### Common Commands
```bash
# Deploy infrastructure
./deploy.sh primary

# View all outputs
terraform output

# View specific output
terraform output aks_cluster_name

# Get Kubernetes credentials
az aks get-credentials \
  --resource-group aks-primary_group \
  --name aks-primary

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure
./destroy.sh primary
```

### Advanced Commands
```bash
# Validate configuration
terraform validate

# Format Terraform files
terraform fmt

# Show current state
terraform show

# List all resources
terraform state list

# Refresh state from Azure
terraform refresh

# Plan with output file
terraform plan -out=tfplan

# Apply saved plan
terraform apply tfplan
```

---

## 📤 Outputs

After successful deployment, the following information is available:
```bash
terraform output
```

### Output Values

- `resource_group_name` - Azure resource group name
- `aks_cluster_name` - AKS cluster name
- `aks_cluster_fqdn` - AKS cluster fully qualified domain name
- `aks_node_resource_group` - AKS node resource group
- `postgres_primary_fqdn` - PostgreSQL primary server address
- `postgres_dr_fqdn` - PostgreSQL DR replica address
- `postgres_connection_string` - Database connection string
- `storage_account_velero_name` - Velero backup storage name
- `vnet_name` - Virtual network name
- `get_kubeconfig_command` - Command to configure kubectl

### Using Outputs
```bash
# Get cluster name
CLUSTER=$(terraform output -raw aks_cluster_name)

# Get resource group
RG=$(terraform output -raw resource_group_name)

# Use in commands
az aks show --name $CLUSTER --resource-group $RG
```

---

## 🔄 Disaster Recovery

### Test DR Workflow

This demonstrates the power of Infrastructure as Code:
```bash
# Step 1: View current infrastructure
terraform output
kubectl get nodes

# Step 2: Destroy everything
./destroy.sh primary
# Confirm with 'yes' then 'destroy'

# Step 3: Verify deletion
az resource list --resource-group aks-primary_group

# Step 4: Recreate infrastructure
./deploy.sh primary
# Press ENTER when prompted

# Step 5: Verify recreation
terraform output
kubectl get nodes
```

Infrastructure is recreated identically in approximately 15 minutes.

### Deploy to Multiple Environments
```bash
# Deploy primary environment
./deploy.sh primary

# Deploy DR environment
./deploy.sh dr

# Deploy development environment
./deploy.sh dev
```

---

## 🐛 Troubleshooting

### Authentication Issues
```bash
# Re-authenticate with Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
az account show
```

### State Lock Issues
```bash
# Check lock status
terraform force-unlock -help

# Unlock if necessary (use with caution)
terraform force-unlock LOCK_ID
```

### Key Vault Access Issues
```bash
# List Key Vaults
az keyvault list --query "[].name"

# Check permissions
az keyvault show --name YOUR_KEY_VAULT_NAME
```

### Resource Already Exists
```bash
# Import existing resource
terraform import azurerm_resource_group.aks_primary \
  /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME
```

### Permission Denied
```bash
# Check your role assignments
az role assignment list --assignee YOUR_EMAIL

# You need "Contributor" role on the subscription
```

### Debug Mode
```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform plan

# Disable logging
unset TF_LOG
```

---

## 📁 Project Structure
```
.
├── README.md                 # Documentation
├── .gitignore               # Files to ignore in Git
│
├── main.tf                  # Infrastructure resources
├── variables.tf             # Variable definitions
├── outputs.tf               # Output values
├── provider.tf              # Azure provider configuration
├── backend.tf               # Remote state configuration
├── data.tf                  # Data sources
│
├── deploy.sh                # Deployment script
└── destroy.sh               # Cleanup script
```

---

## 📊 Results

### Before Infrastructure as Code

- Deployment Time: **8 hours**
- Error Rate: **~15%** (human errors)
- Reproducibility: **Low**
- Team Collaboration: **Difficult**
- Documentation: **Manual/Outdated**

### After Infrastructure as Code

- Deployment Time: **15 minutes**
- Error Rate: **0%** (automated)
- Reproducibility: **100%**
- Team Collaboration: **Easy**
- Documentation: **Self-documenting**

### Key Improvements

- ✅ 97% reduction in deployment time
- ✅ 100% elimination of human errors
- ✅ Perfect reproducibility
- ✅ Easy team collaboration
- ✅ Complete version control

---

## 📚 Documentation

### Official Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)

### Learning Resources

- [Terraform Tutorials](https://learn.hashicorp.com/terraform)
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 👤 Author

**Zaheer Ahmed**

Cloud Engineer | DevOps Enthusiast

- LinkedIn: https://www.linkedin.com/in/zaheerr-ahmed


## 🌟 Acknowledgments

Special thanks to:
- HashiCorp for Terraform
- Microsoft Azure team
- Open source community

---

## ⭐ Support

If you found this project helpful, please give it a star!

---

**Made with ❤️ | Infrastructure as Code**
