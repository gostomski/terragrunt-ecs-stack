include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling?ref=v3.8.0"
}

locals {
  # Automatically load environment-level variables
  env   = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  vpc   = yamldecode(file(find_in_parent_folders("env.yaml")))["vpc"]
  name = "asg-${local.env["name"]}-${local.env["environment"]}"
}


dependency "instance-profile" {
  config_path = "../ecs/instance-profile"

  mock_outputs = {
    this_iam_instance_profile_id  = "fake-iam-instance-profile-id"
  }
}

dependency "sg" {
  config_path = "../ecs/sg"

  mock_outputs = {
    this_security_group_id = "fake-mc-sub-00001-id"
  }
}

inputs = {
  name = local.name

  # Launch configuration
  lc_name = local.name

  #image_id             = data.aws_ami.amazon_linux_ecs.id
  #image_id             = "ami-014ae578"
  image_id             = "ami-0749ff158d82fc5ee"
  instance_type        = "t3.medium"
  security_groups      = [dependency.sg.outputs.this_security_group_id]
  iam_instance_profile = dependency.instance-profile.outputs.this_iam_instance_profile_id
  user_data            = templatefile("user_data.sh", { cluster_name = "${local.env["name"]}-${local.env["environment"]}-ecs-cluster" })

  # Auto scaling group
  asg_name                  = local.name
  vpc_zone_identifier       = local.vpc["public_subnets_ids"]
  #vpc_zone_identifier       = dependency.vpc.outputs.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1 # we don't need them for the example
  wait_for_capacity_timeout = 0
  associate_public_ip_address = true
  key_name = "grzes"

  tags = [
    {
      key                 = "Environment"
      value               =  local.env["environment"]
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${local.env["name"]}-${local.env["environment"]}-ecs-cluster"
      propagate_at_launch = true
    },
  ]
}

