terraform {
  source = "../../../modules//app-service-containers"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "resonanz-tmpl-prod-rg"
  environment      = "prod"
  docker_image     = "nginx"
  docker_image_tag = "latest"
  sku_name         = "P1v2"
  always_on        = true
  app_settings = {
    "WEBSITES_PORT" = "80"
  }
}
