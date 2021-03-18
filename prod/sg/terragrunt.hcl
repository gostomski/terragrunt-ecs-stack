include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env  = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["env"]
  name = "alb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "fake-vpc-id"
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group?ref=v3.16.0"
}

inputs = {
  name        = "${local.env["prefix"]}-${local.name}-${local.env["environment"]}"
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}
