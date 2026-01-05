include {
  path = find_in_parent_folders("root.hcl")
}

# Задаваме специфични за PROD променливи
inputs = {
  environment         = "prod"
  resource_group_name = "resonanz-tmpl-prod-rg"
  vm_size             = "Standard_B4ms" # Голям размер за production
  vm_count            = 5               # 5 виртуални машини в prod
  tags = {
    CostCenter = "Production"
  }
}
