# Terraform Bootstrap

This directory contains Terraform configuration to bootstrap the Azure backend infrastructure for storing Terraform state files.

## What It Does

The bootstrap configuration creates the necessary Azure resources for Terraform remote state storage:

1. **Resource Group** - Creates the resource group if it doesn't exist
2. **Storage Account** - Creates the storage account if it doesn't exist
3. **Storage Container** - Creates the blob container if it doesn't exist

## Smart Resource Management

The bootstrap is designed to be **idempotent** - it checks if resources already exist and only creates them if they're missing:

- ✅ If a resource exists, it will be detected and used
- ✅ If a resource doesn't exist, it will be created
- ✅ Safe to run multiple times without errors
- ✅ No manual intervention needed

## Usage

### Local Execution

```bash
cd bootstrap

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### Pipeline Execution

The bootstrap stage is integrated into `azure-pipeline.yml` and runs automatically before other stages:

1. **Bootstrap Stage** - Creates/validates backend resources
2. **Plan Stage** - Plans infrastructure changes
3. **Apply Stage** - Applies infrastructure changes
4. **Destroy Stage** - Destroys infrastructure (manual trigger)

The bootstrap stage will:
- Check for existing resources
- Create only missing resources
- Output the storage account name for use in subsequent stages
- Report what was created vs. what already existed

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `resource_group_name` | Name of the resource group | `RCA-AZ-RG-TFSTATES` | No |
| `location` | Azure region | `westeurope` | No |
| `storage_account_prefix` | Prefix for storage account name | `tfstate` | No |
| `storage_account_name` | Full storage account name (optional) | `null` | No |
| `deployment_name` | Deployment name for unique container | `default` | No |
| `container_name` | Full container name (optional, generated from deployment_name if not set) | `null` | No |

### Custom Configuration

Create a `terraform.tfvars` file to override defaults:

```hcl
resource_group_name    = "my-rg-tfstate"
location              = "northeurope"
storage_account_name  = "mystorageaccount123"
deployment_name       = "prod-env"
```

**Note on Container Names:**
- If you don't specify `container_name`, it will be auto-generated as `tfstate-{deployment_name}`
- For example, with `deployment_name = "prod-env"`, the container will be `tfstate-prod-env`
- This ensures each deployment has its own unique container for state isolation
- If you prefer a specific container name, set `container_name` explicitly

**Examples:**

```hcl
# Example 1: Multiple environments with unique containers
deployment_name = "dev"      # Creates container: tfstate-dev
# deployment_name = "staging" # Creates container: tfstate-staging
# deployment_name = "prod"    # Creates container: tfstate-prod

# Example 2: Explicit container name (overrides deployment_name)
container_name = "my-custom-tfstate"

# Example 3: Default behavior
# deployment_name defaults to "default" → container: tfstate-default
```

## Outputs

The bootstrap provides the following outputs:

- `resource_group_name` - Name of the resource group
- `resource_group_location` - Location of the resource group
- `storage_account_name` - Name of the storage account
- `storage_account_id` - ID of the storage account
- `container_name` - Name of the storage container
- `storage_account_primary_access_key` - Access key (sensitive)
- `resource_group_created` - Whether the RG was created (true/false)
- `storage_account_created` - Whether the SA was created (true/false)
- `container_created` - Whether the container was created (true/false)

## How It Works

The bootstrap uses Terraform data sources with error handling to check for existing resources:

```hcl
# Try to get existing resource
data "azurerm_resource_group" "existing" {
  count = 1
  name  = var.resource_group_name
  # Will be null if not found
}

# Create only if it doesn't exist
resource "azurerm_resource_group" "tfstate" {
  count = try(data.azurerm_resource_group.existing[0].id, null) == null ? 1 : 0
  # ... resource configuration
}
```

This pattern is applied to:
1. Resource Group
2. Storage Account
3. Storage Container

## Pipeline Integration

The bootstrap stage in `azure-pipeline.yml`:

```yaml
stages:
  - stage: bootstrap
    displayName: "Bootstrap Infrastructure"
    jobs:
      - job: bootstrap
        displayName: "Create Backend Storage"
        steps:
          - task: AzureCLI@2
            displayName: "Bootstrap Terraform Backend"
            # ... runs terraform in bootstrap directory
```

Key features:
- Runs before all other stages
- Uses Azure CLI authentication
- Outputs storage account name for subsequent stages
- Reports what was created vs. existing

## Security

The bootstrap configuration includes security best practices:

- ✅ TLS 1.2 minimum
- ✅ HTTPS-only traffic
- ✅ Private container access
- ✅ No public blob access
- ✅ Sensitive outputs marked appropriately

## Troubleshooting

### "Resource already exists" error

This shouldn't happen with the new idempotent design. If you see this:
1. Check that the data source is properly configured
2. Verify Azure credentials have read permissions

### Storage account name conflicts

If auto-generated names conflict:
1. Set `storage_account_name` variable explicitly
2. Or change `storage_account_prefix` to something unique

### Permission issues

Ensure your service principal has:
- `Contributor` role on the subscription
- Or specific permissions to create resource groups and storage accounts

## State Management

⚠️ **Important**: The bootstrap itself does NOT use remote state. It stores state locally since it's creating the remote backend.

After bootstrap runs, all other Terraform/Terragrunt configurations will use the created backend for remote state storage.

## Maintenance

### Updating Resources

To update existing resources:
1. The bootstrap will detect existing resources
2. Modify the resource configuration as needed
3. Run `terraform apply` - only changes will be applied

### Destroying Resources

⚠️ **Warning**: Destroying the bootstrap resources will delete all Terraform state files!

```bash
cd bootstrap
terraform destroy
```

Only do this if you're completely removing the infrastructure.
