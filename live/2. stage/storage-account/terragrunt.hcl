terraform {
  source = "../../../modules//storage-account"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment              = "stage"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  containers = [
    {
      name        = "documents"
      access_type = "private"
    },
    {
      name        = "images"
      access_type = "private"
    }
  ]
}
