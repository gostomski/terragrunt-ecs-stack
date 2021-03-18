locals {
  # Automatically load environment-level variables
  environment_vars = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["env"]

  # Extract the variables we need for easy access
  aws_region     = local.environment_vars.aws_region
  env            = local.environment_vars.environment
  name           = local.environment_vars.name
}


# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  profile = "${local.name}"
  region  = "${local.aws_region}"
  version = ">= 3.1"
}
EOF
}


# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.name}-${local.env}-terragrunt-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "${local.name}-${local.env}-terragrunt-lock"
    profile        = "${local.name}"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

}


terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 15 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint",
      "show",
    ]

    arguments = [
      "-lock-timeout=5m",
    ]

  }

  extra_arguments "default_vars" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint",
    ]
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = {
  tags = yamldecode(file("${find_in_parent_folders("env.yaml")}"))["tags"]
}
