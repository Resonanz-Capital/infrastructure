include {
  path = find_in_parent_folders("root.hcl")
}

# Задаваме специфични за DEV променливи
inputs = {
  environment         = "dev"
  resource_group_name = "resonanz-tmpl-dev-rg"
  vm_size             = "Standard_B2s" # Най-малък и евтин размер за разработка
  vm_count            = 2              # Само 2 виртуални машини в dev
  tags = {
    CostCenter = "R&D"
  }
}
