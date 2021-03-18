include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling?ref=v3.8.0"
}

locals {
  # Automatically load environment-level variables
  env   = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  name = "asg-${local.env["name"]}-${local.env["environment"]}"
  #ec2_resources_name = "${local.name}-${local.environment}"
  #local.env["environment"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "fake-vpc-id"
    public_subnets  = ["fake-sub-pub-00001", "fake-sub-pub-00002", "fake-sub-pub-00003"]
    private_subnets = ["fake-sub-priv-00001","fake-sub-priv-00002","fake-sub-priv-00003"]
  }
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

dependency "keypair" {
  config_path = "../keypair"

  mock_outputs = {
    this_key_pair_key_name = "fake-name"
  }
}

inputs = {
  name = local.name

  # Launch configuration
  lc_name = local.name

  #image_id             = data.aws_ami.amazon_linux_ecs.id
  image_id             = "ami-0749ff158d82fc5ee"
  instance_type        = "t2.small"
  security_groups      = [dependency.sg.outputs.this_security_group_id]
  iam_instance_profile = dependency.instance-profile.outputs.this_iam_instance_profile_id
  user_data            = templatefile("user_data.sh", { cluster_name = "${local.env["name"]}-${local.env["environment"]}-ecs-cluster", aws_region = local.env["aws_region"] })

  # Auto scaling group
  asg_name                  = local.name
  vpc_zone_identifier       = dependency.vpc.outputs.public_subnets
  #vpc_zone_identifier       = dependency.vpc.outputs.private_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1 # we don't need them for the example
  wait_for_capacity_timeout = 0
  associate_public_ip_address = true
  key_name = dependency.keypair.outputs.this_key_pair_key_name

/*  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]
*/
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

