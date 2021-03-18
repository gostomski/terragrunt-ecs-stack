include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env  = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  vpc  = yamldecode(file(find_in_parent_folders("env.yaml")))["vpc"]
  alb  = yamldecode(file(find_in_parent_folders("env.yaml")))["alb"]
  name = "eldor24"
}

terraform {
  source = "../../../../modules/aws-ecs/service"
}


dependency "cluster" {
  config_path = "../../../ecs/cluster"

  mock_outputs = {
    this_ecs_cluster_arn = "fake-arn-ecs"
    this_ecs_cluster_name = "fake-name-ecs"
  }
}

dependency "kms" {
  config_path = "../../../kms"

  mock_outputs = {
    key_arn = "fake-c5f0ff64-d0fe-4fe3-9df0-f366133c188d"
  }
}


dependency "td" {
  config_path = "../task"

  mock_outputs = {
    aws_ecs_task_definition_td_arn = "arn:aws:ecs:eu-central-1:0000000000000001:task-definition/prestashop-td:1"
  }
}

inputs = {
  name                            = local.name
  environment                     = local.env["environment"]

  ecs_cluster_arn                 = dependency.cluster.outputs.this_ecs_cluster_arn
  ecs_cluster_name                = dependency.cluster.outputs.this_ecs_cluster_name

  ecs_vpc_id                      = local.vpc["vpc_id"]
  ecs_subnet_ids                  = local.vpc["private_subnets_ids"]
  kms_key_id                      = dependency.kms.outputs.key_arn

  associate_nlb = false
  associate_alb = true
  nlb_subnet_cidr_blocks          = local.vpc["private_subnets"]
  
  ecs_use_fargate  = false
  assign_public_ip = false

  lb_target_groups = [
    {
      container_port              = 80
      container_health_check_port = 80  
      lb_target_group_arn         = local.alb["lb_target_group_arn"]
    }
  ]
  
  target_container_name           = "prestashop"
  tasks_desired_count             = 1
  task_definition_arn             = dependency.td.outputs.aws_ecs_task_definition_td_arn
  logs_cloudwatch_group           = "/ecs/service/${local.env["name"]}-${local.env["environment"]}-${local.name}"
}
