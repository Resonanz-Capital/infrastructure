include {
  path = find_in_parent_folders("root.hcl")
}

# Задаваме специфични за STAGE променливи
inputs = {
  environment         = "stage"
  resource_group_name = "resonanz-tmpl-stage-rg"
  vm_size             = "Standard_B2ms" # По-голям размер за staging
  vm_count            = 3               # 3 виртуални машини в stage
  tags = {
    CostCenter = "Staging"
  }
}
