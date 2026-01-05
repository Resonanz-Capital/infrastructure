terraform {
  source = "../../../modules//app-service-containers"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment = "dev"
  docker_image     = "nginx"
  docker_image_tag = "latest"
  sku_name         = "B1"
  always_on        = true
  app_settings = {
    "WEBSITES_PORT" = "80"
  }
}
