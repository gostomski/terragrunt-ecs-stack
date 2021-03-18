include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs?ref=v2.7.0"
}

inputs = {
  name = "${local.env["name"]}-${local.env["environment"]}-ecs-cluster"
}
