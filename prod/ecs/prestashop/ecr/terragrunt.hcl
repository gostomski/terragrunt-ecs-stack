include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  tags = yamldecode(file(find_in_parent_folders("env.yaml")))["tags"]
  service_name = "prestashop"
}

terraform {
  source = "../../../../modules/ecr/"
}

inputs = {
  repo_name               = "${local.env["environment"]}-${local.service_name}"
  ecs_service_name        = local.service_name
  create_lifecycle_policy = true
  tags                    = merge(local.tags, {service_name=local.service_name})
}