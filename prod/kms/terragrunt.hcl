include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
}

terraform {
  source = "../../modules/aws-kms"
}

inputs = {
  namespace               = local.env["name"]
  env                     = local.env["environment"]
  aws_region              = local.env["aws_region"]
}
