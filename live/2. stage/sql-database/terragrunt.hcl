terraform {
  source = "../../../modules//sql-database"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment                  = "stage"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password123!"
  sku_name                     = "S0"
  max_size_gb                  = 250
  firewall_rules = [
    {
      name     = "AllowAllAzure"
      start_ip = "0.0.0.0"
      end_ip   = "0.0.0.0"
    }
  ]
}
