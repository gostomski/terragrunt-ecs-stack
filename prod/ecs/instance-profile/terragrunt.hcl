include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
}

terraform {
  #source = "github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/ecs-instance-profile?ref=v2.7.0"
  source = "../../../modules/aws-ecs/ecs-instance-profile"
}

inputs = {
  name = "${local.env["name"]}-${local.env["environment"]}-ec2-profile"
}
