# Bootstrap Module

This module creates the initial Azure infrastructure required for Terraform remote state management. It should be executed once locally before running the main infrastructure modules.

## Resources Created

1. **Resource Group** - Contains all bootstrap resources
2. **Storage Account** - Used for storing Terraform state files
3. **Storage Container** - Container within the storage account for state files

## Prerequisites

- Azure CLI authenticated with appropriate permissions
- Terraform installed

## Usage

1. Navigate to the bootstrap directory:
   ```bash
   cd bootstrap
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the infrastructure:
   ```bash
   terraform plan
   ```

4. Apply the infrastructure:
   ```bash
   terraform apply
   ```

## Important Notes

- This module should only be run once
- The resources created here are critical for remote state management
- Do not delete these resources unless you're destroying the entire infrastructure
- After running this module, you can use the main infrastructure modules with remote state

## Outputs

The module outputs the following values that are used in the main infrastructure configuration:

- `resource_group_name` - Name of the resource group
- `storage_account_name` - Name of the storage account
- `container_name` - Name of the storage container
