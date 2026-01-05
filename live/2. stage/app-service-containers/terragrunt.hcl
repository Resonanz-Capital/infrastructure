terraform {
  source = "../../../modules//app-service-containers"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment      = "stage"
  docker_image     = "nginx"
  docker_image_tag = "latest"
  sku_name         = "S1"
  always_on        = true
  app_settings = {
    "WEBSITES_PORT" = "80"
  }
}
