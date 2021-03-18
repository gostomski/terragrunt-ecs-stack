include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v2.68.0"
}

locals {
  # Automatically load environment-level variables
  env   = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  vpc   = yamldecode(file(find_in_parent_folders("env.yaml")))["vpc"]
}

inputs = {
  name = "vpc-${local.env["name"]}-${local.env["environment"]}"
  cidr = local.vpc["cidr"]

  azs                  = ["${local.env["aws_region"]}a", "${local.env["aws_region"]}b"]
  private_subnets      = local.vpc["private_subnets"]
  public_subnets       = local.vpc["public_subnets"]
  enable_nat_gateway  = true
  single_nat_gateway  = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

