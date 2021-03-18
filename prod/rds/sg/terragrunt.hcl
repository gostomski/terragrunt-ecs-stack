include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env  = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["env"]
  name = "rds-mariadb"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    vpc_id = "fake-vpc-id"
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group?ref=v3.16.0"
}

inputs = {
  name        = "${local.env["prefix"]}-${local.name}-${local.env["environment"]}"
  description = "Security group for ${local.name} instance"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8","80.52.242.201/32","79.190.200.232/32"]
  ingress_rules       = ["all-icmp","mysql-tcp"]
  egress_rules        = ["all-all"]
}
