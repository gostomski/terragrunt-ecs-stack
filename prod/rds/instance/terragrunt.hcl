include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  name = "mariadb"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v2.18.0"
}

dependency "vpc" {
  config_path = "../../vpc"

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

  identifier = local.name

  engine            = "mariadb"
  engine_version    = "10.2.32"
  instance_class    = "db.t3.micro"
  allocated_storage = 5
  storage_encrypted = true

  name = local.name

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username              = "xxxxx"
  password              = "yyyyyyyyyyyyyyyyyyyyyyy"
  port                  = "3306"

  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]

  maintenance_window = "sun:05:00-sun:06:00"
  backup_window      = "02:00-03:00"

  enabled_cloudwatch_logs_exports = ["audit", "general"]

  # DB subnet group
  #subnet_ids = dependency.vpc.outputs.private_subnets
  subnet_ids = dependency.vpc.outputs.public_subnets

  publicly_accessible = true

  # DB parameter group
  family = "mariadb10.2"

  # DB option group
  major_engine_version = "10.2"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "snap-${local.env["name"]}-${local.env["environment"]}"

  # Database Deletion Protection
  deletion_protection = false
  multi_az = false
  auto_minor_version_upgrade = false
# disable backups to create DB faster
  backup_retention_period = 0
}