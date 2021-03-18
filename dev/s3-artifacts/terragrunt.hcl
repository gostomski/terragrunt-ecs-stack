include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  tags = yamldecode(file(find_in_parent_folders("env.yaml")))["tags"]
}

terraform {
  source = "../../modules/aws-s3/bucket/"
}

inputs = {
  name                    = "${local.env["name"]}-${local.env["environment"]}-eldor24-s3-artifacts-bucket"
  tags                    = local.tags
}