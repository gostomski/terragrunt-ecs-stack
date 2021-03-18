include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env  = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["env"]
  vpc  = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["vpc"]
  name = "ecs"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group?ref=v3.17.0"
}

inputs = {
  name        = "${local.env["prefix"]}-${local.name}-${local.env["environment"]}"
  description = "Security group for ${local.name} EC2 instance"
  vpc_id      = local.vpc["vpc_id"]

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}
