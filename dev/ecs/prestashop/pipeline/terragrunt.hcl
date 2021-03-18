include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  env = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  tags = yamldecode(file(find_in_parent_folders("env.yaml")))["tags"]
  service_name = "eldor24"
  full_repo_id = "projekty-dihpl/eldor24.pl"
  pipeline = yamldecode(file(find_in_parent_folders("env.yaml")))["pipeline"]

  codestar_connection_arn = yamldecode(file(find_in_parent_folders("env.yaml")))["pipeline"]["codestar_connection_arn"]
}

terraform {
  source = "../../../../modules/aws-codesuite/backend-pipeline/"
}

dependency "kms" {
  config_path = "../../../kms/"

  mock_outputs = {
    alias_arn = "arn:aws:kms:xx-yyyy-z:0000000000001:alias/bla-bla-bla"
    key_arn = "arn:aws:kms:xx-yyyy-z:0000000000001:key/f966422a-f8a8-de14-1111-ff017996953a"
  }
}

dependency "ecr" {
  config_path = "../ecr/"

  mock_outputs = {
    repository_arn = "arn:aws:ecr:xx-yyyy-z:sakkwqdlk:repository/xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    repository_name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}

dependency "artifacts" {
  config_path = "../../../s3-artifacts/"

  mock_outputs = {

    bucket_arn = "arn:aws:s3:bucket-XXXXXXXXXX"
    bucket_name = "ZZZ"
  }
}

dependency "ecs-cluster" {
  config_path = "../../../ecs/cluster/"

  mock_outputs = {
    this_ecs_cluster_name = "ecs-cluster-name"
  }
}

dependency "ecs-service" {
  config_path = "../service/"

  mock_outputs = {
    service_name = "ecs-service-name"
  }
}

inputs = {
  basic_name                  = "${local.env.name}-${local.env.environment}-${local.service_name}"
  codebuild_tags              = merge(local.tags, {service_name=local.service_name})
  app_ecr_repo_name           = dependency.ecr.outputs.repository_name
  ecr_repo_arn                = dependency.ecr.outputs.repository_arn
  artifact_bucket_arn         = dependency.artifacts.outputs.bucket_arn
  codebuild_ssm_params_path_arn = "parameter/dih/all/codebuild/*"
  kms_key                     = dependency.kms.outputs.key_arn
  kms_alias                   = dependency.kms.outputs.alias_arn
  aws_region                  = local.env.aws_region

  codestar_connection_arn     = local.pipeline["codestar_connection_arn"]
  repo_branch                 = local.pipeline["source_branch"]
  full_repo_id                = local.full_repo_id
  ecs_cluster_name            = dependency.ecs-cluster.outputs.this_ecs_cluster_name
  ecs_service_name            = dependency.ecs-service.outputs.service_name
  artifact_bucket_name        = dependency.artifacts.outputs.bucket_name
}