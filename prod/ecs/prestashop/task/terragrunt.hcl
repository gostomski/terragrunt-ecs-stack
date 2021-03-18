include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env  = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  vpc  = yamldecode(file(find_in_parent_folders("env.yaml")))["vpc"]
  name = "eldor24"
}

terraform {
  source = "../../../../modules/aws-ecs/task-definition"
}


dependency "rds" {
  config_path = "../../../rds/instance/"

  mock_outputs = {
    this_db_instance_address = "rdspostgres.cbahhkkgxxx.eu-central-1.rds.amazonaws.com"
  }
}

dependency "kms" {
  config_path = "../../../kms/"

  mock_outputs = {
    alias_arn = "arn:aws:kms:xx-yyyy-z:0000000000001:alias/bla-bla-bla"
    key_arn = "arn:aws:kms:xx-yyyy-z:0000000000001:key/f966422a-f8a8-de14-1111-ff017996953a"
  }
}

inputs = {
  kms_key                      = dependency.kms.outputs.key_arn
  kms_alias                    = dependency.kms.outputs.alias_arn

  name_prefix                  = local.name
  aws_region                   = local.env["aws_region"]

  container_name               = "prestashop"
  container_image              = "372610613424.dkr.ecr.eu-central-1.amazonaws.com/prod-prestashop"
  essential                    = true
  readonly_root_filesystem     = false
  environment                  = [
    {
      name = "DB_SERVER",
      value = dependency.rds.outputs.this_db_instance_address
    },
    {
      name = "DB_USER",
      value = "eldor24_presta"
    },
    {
      name = "DB_NAME",
      value = "eldor24_presta"
    },
    {
      name = "DB_PASSWD",
      value = "xxxxxxxxxxxxxxxxxxxxxxx"
    },
    {
      name = "PS_DEMO_MODE",
      value = "0"
    },
    {
      name = "PS_INSTALL_AUTO",
      value = "0"
    },
    {
      name = "PS_FOLDER_ADMIN",
      value = "adminxxxxxxxxxxxxx"
    },
    {
      name = "PS_UPDATE_SETTING",
      value = "1"
    },
  ]
  command                      = []
  mount_points = [
    {
        sourceVolume = "rexray-vol-img",
        containerPath = "/var/www/html/img",
        readOnly = false
    }
  ]
  volumes = [  
    { 
      host_path = null,
      name = "rexray-vol-img",
      docker_volume_configuration = [{
        autoprovision = true,
        scope = "shared",
        labels = {
          name = "presta-rexray-vol-img"
        }
        driver = "rexray/ebs",
        driver_opts = {
          volumetype = "gp2",
          size = "5"
        }
      }]
      efs_volume_configuration = [],
    },
  ]
  port_mappings                = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    },
  ]
  log_configuration = {
        logDriver = "awslogs",
        secretOptions = null,
        options = {
          awslogs-group = "/ecs/service/${local.env["name"]}-${local.env["environment"]}-${local.name}",
          awslogs-region = local.env["aws_region"],
          awslogs-stream-prefix = "ecs"
        }
  }
  task_memory                   = 2048
}
