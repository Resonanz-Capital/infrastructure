#!/bin/bash

# Validation script for Terraform/Terragrunt Azure infrastructure

echo "Validating Terraform/Terragrunt Azure Infrastructure Setup"
echo "========================================================="

# Check if required tools are installed
echo "Checking prerequisites..."
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
else
    echo "✅ Terraform is installed"
fi

if ! command -v terragrunt &> /dev/null; then
    echo "❌ Terragrunt is not installed"
    exit 1
else
    echo "✅ Terragrunt is installed"
fi

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed"
    exit 1
else
    echo "✅ Azure CLI is installed"
fi

# Check directory structure
echo
echo "Checking directory structure..."
REQUIRED_DIRS=(
    "modules/vnet"
    "modules/vpn-gateway"
    "modules/application-gateway"
    "modules/acr"
    "modules/app-service"
    "modules/app-service-containers"
    "modules/sql-database"
    "modules/redis-cache"
    "modules/storage-account"
    "modules/log-analytics"
    "modules/diagnostic-settings"
    "modules/alerting"
    "live/1. dev/vnet"
    "live/1. dev/vpn-gateway"
    "live/1. dev/application-gateway"
    "live/1. dev/acr"
    "live/1. dev/app-service"
    "live/1. dev/app-service-containers"
    "live/1. dev/sql-database"
    "live/1. dev/redis-cache"
    "live/1. dev/storage-account"
    "live/1. dev/log-analytics"
    "live/1. dev/diagnostic-settings"
    "live/1. dev/alerting"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "❌ Directory $dir is missing"
        exit 1
    else
        echo "✅ Directory $dir exists"
    fi
done

# Check if required files exist
echo
echo "Checking required files..."
REQUIRED_FILES=(
    "README.md"
    "live/root.hcl"
    "live/1. dev/terragrunt.hcl"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ File $file is missing"
        exit 1
    else
        echo "✅ File $file exists"
    fi
done

# Check Terraform modules
echo
echo "Checking Terraform modules..."
MODULES=(
    "vnet"
    "vpn-gateway"
    "application-gateway"
    "acr"
    "app-service"
    "app-service-containers"
    "sql-database"
    "redis-cache"
    "storage-account"
    "log-analytics"
    "diagnostic-settings"
    "alerting"
)

# Check bootstrap module
echo
echo "Checking bootstrap module..."
if [ ! -f "bootstrap/main.tf" ] || [ ! -f "bootstrap/variables.tf" ] || [ ! -f "bootstrap/outputs.tf" ]; then
    echo "❌ Bootstrap module is incomplete"
    exit 1
else
    echo "✅ Bootstrap module is complete"
fi

for module in "${MODULES[@]}"; do
    if [ ! -f "modules/$module/main.tf" ] || [ ! -f "modules/$module/variables.tf" ] || [ ! -f "modules/$module/outputs.tf" ]; then
        echo "❌ Module $module is incomplete"
        exit 1
    else
        echo "✅ Module $module is complete"
    fi
done

# Check Terragrunt configurations
echo
echo "Checking Terragrunt configurations..."
ENVIRONMENTS=("1. dev")
MODULES=(
    "vnet"
    "vpn-gateway"
    "application-gateway"
    "acr"
    "app-service"
    "app-service-containers"
    "sql-database"
    "redis-cache"
    "storage-account"
    "log-analytics"
    "diagnostic-settings"
    "alerting"
)

for env in "${ENVIRONMENTS[@]}"; do
    for module in "${MODULES[@]}"; do
        if [ ! -f "live/$env/$module/terragrunt.hcl" ]; then
            echo "❌ Terragrunt config for $module in $env is missing"
            exit 1
        else
            echo "✅ Terragrunt config for $module in $env exists"
        fi
    done
done

echo
echo "🎉 All validations passed! Your Terraform/Terragrunt Azure infrastructure is ready."
echo
echo "Next steps:"
echo "1. Authenticate to Azure: az login"
echo "2. Navigate to an environment: cd live/1. dev"
echo "3. Initialize Terragrunt: terragrunt init"
echo "4. Plan the infrastructure: terragrunt plan"
echo "5. Apply the infrastructure: terragrunt apply"
