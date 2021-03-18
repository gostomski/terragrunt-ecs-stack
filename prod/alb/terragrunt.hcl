include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  tags = yamldecode(file(find_in_parent_folders("env.yaml")))["tags"]
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v5.10.0"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "fake-vpc-id"
    public_subnets  = ["fake-sub-pub-00001", "fake-sub-pub-00002", "fake-sub-pub-00003"]
    private_subnets = ["fake-sub-priv-00001","fake-sub-priv-00002","fake-sub-priv-00003"]
  }
}

dependency "sg" {
 config_path = "../sg"

 mock_outputs = {
   this_security_group_id = "fake-mc-sub-00001-id"
 }
}

inputs = {

  load_balancer_type = "application"
  internal = false
  ip_address_type = "ipv4"
  name = "${local.env["name"]}-${local.env["environment"]}-alb"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  security_groups = [dependency.sg.outputs.this_security_group_id]

  #enable_cross_zone_load_balancing = true

  http_tcp_listeners = [
    # Forward action is default, either when defined or undefined
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:eu-central-1:372610613424:certificate/f3c62ed2-239b-4128-bcb9-e4c96e986c11"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      #target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 120
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        #matcher             = "200-399"
        matcher             = "200-499"
      }
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    },
    {
      name_prefix          = "dev-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      #target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 120
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        #matcher             = "200-399"
        matcher             = "200-499"
      }
      tags = {
        InstanceTargetGroupTag = "dev"
      }
    }
  ]

  https_listener_rules = [
  {
    https_listener_index = 0
    #priority             = 2

    actions = [
      {
        type               = "forward"
        target_group_index = 1
      }
    ]

    conditions = [{
      host_headers = ["dev.eldor24.pl"]
    }]
  }
  ]

}
