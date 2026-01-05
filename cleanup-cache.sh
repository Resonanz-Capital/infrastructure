#!/bin/bash
# Cleanup script for Terragrunt and Terraform cache files

set -e

echo "🧹 Cleaning up Terragrunt and Terraform cache files..."
echo ""

# Count files before cleanup
TERRAGRUNT_CACHE=$(find . -type d -name ".terragrunt-cache" 2>/dev/null | wc -l)
TERRAFORM_CACHE=$(find . -type d -name ".terraform" 2>/dev/null | wc -l)
LOCK_FILES=$(find . -name ".terraform.lock.hcl" -type f 2>/dev/null | wc -l)
BACKEND_FILES=$(find . -name "backend.tf" -type f 2>/dev/null | wc -l)
PROVIDER_FILES=$(find . -name "provider.tf" -type f 2>/dev/null | wc -l)

echo "Found:"
echo "  - $TERRAGRUNT_CACHE .terragrunt-cache directories"
echo "  - $TERRAFORM_CACHE .terraform directories"
echo "  - $LOCK_FILES .terraform.lock.hcl files"
echo "  - $BACKEND_FILES backend.tf files"
echo "  - $PROVIDER_FILES provider.tf files"
echo ""

read -p "Proceed with cleanup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "Cleaning..."

# Remove Terragrunt cache
echo "  ↳ Removing .terragrunt-cache directories..."
find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true

# Remove Terraform cache
echo "  ↳ Removing .terraform directories..."
find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

# Remove lock files
echo "  ↳ Removing .terraform.lock.hcl files..."
find . -name ".terraform.lock.hcl" -type f -delete 2>/dev/null || true

# Remove Terragrunt-generated files
echo "  ↳ Removing backend.tf files..."
find . -name "backend.tf" -type f -delete 2>/dev/null || true

echo "  ↳ Removing provider.tf files..."
find . -name "provider.tf" -type f -delete 2>/dev/null || true

# Optional: Remove local state files (commented out for safety)
# echo "  ↳ Removing terraform.tfstate files..."
# find . -name "terraform.tfstate*" -type f -delete 2>/dev/null || true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Next steps:"
echo "  1. cd live/1.\\ dev"
echo "  2. terragrunt init --all"
echo "  3. terragrunt plan --all"
