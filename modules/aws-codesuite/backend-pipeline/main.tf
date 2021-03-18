data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals{
    ecr_repo_arn_units          = split("/", var.ecr_repo_arn)
    ecr_repo_arn_units_new_len  = length(local.ecr_repo_arn_units)-1
    ecr_repo_arn_units_but_last = slice(local.ecr_repo_arn_units, 0, local.ecr_repo_arn_units_new_len)
    ecr_repo_arn_without_suffix = join("/", local.ecr_repo_arn_units_but_last)
}

resource "aws_iam_role" "codebuild_role" {
  name                          = "${var.basic_name}-codebuild-service-role"

  assume_role_policy            = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backend_codebuild_role_policy" {
  role                          = aws_iam_role.codebuild_role.name
  name                          = "backend_codebuild_role_policy"
  policy                        = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "${var.artifact_bucket_arn}/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ],
            "Resource": "${var.artifact_bucket_arn}",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "${local.ecr_repo_arn_without_suffix}/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.codebuild_ssm_params_path_arn}",
            "Effect": "Allow"
        },
        {
            "Action": "kms:Decrypt",
            "Resource": [
                "${var.kms_key}",
                "${var.kms_alias}"
            ],
            "Effect": "Allow"
        }
    ]
}
POLICY
}

resource "aws_codebuild_project" "main" {
  name                          = "${var.basic_name}-codebuild-project"
  build_timeout                 = var.codebuild_timeout
  queued_timeout                = var.codebuild_queued_timeout
  service_role                  = aws_iam_role.codebuild_role.arn
  tags                          = var.codebuild_tags
  artifacts {
    type                        = "CODEPIPELINE"
  }
  source {
    type                        = "CODEPIPELINE"
    buildspec                   = "buildspec.yml"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/docker:18.09.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name                      = "AWS_DEFAULT_REGION"
      value                     = var.aws_region
      type                      = "PLAINTEXT"
    }
    environment_variable {
      name                      = "IMAGE_REPO_NAME_CRON"
      value                     = var.cron_ecr_repo_name
      type                      = "PLAINTEXT"
    }
    environment_variable {
      name                      = "IMAGE_REPO_NAME_PHP_FPM"
      value                     = var.app_ecr_repo_name
      type                      = "PLAINTEXT"
    }
    environment_variable {
      name                      = "IMAGE_REPO_NAME_NGINX"
      value                     = var.proxy_ecr_repo_name
      type                      = "PLAINTEXT"
    }
    environment_variable {
      name                      = "AWS_ACCOUNT_ID"
      value                     = data.aws_caller_identity.current.account_id
      type                      = "PLAINTEXT"
    }
  }
  cache {
    type                        = "LOCAL"
    modes                       = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  depends_on = [
    aws_iam_role_policy.backend_codebuild_role_policy,
  ]
}



resource "aws_iam_role" "codepipeline_role" {
  name                          = "${var.basic_name}-codepipeline-service-role"

  assume_role_policy            = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backend_codepipeline_role_policy" {
  role                          = aws_iam_role.codepipeline_role.name
  name                          = "backend_codepipeline_role_policy"
  policy                        = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObjectAcl"
            ],
            "Resource": "${var.artifact_bucket_arn}/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ecs:DescribeServices",
                "ecs:DescribeTaskDefinition",
                "ecs:DescribeTasks",
                "ecs:ListTasks",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService",
                "iam:PassRole",
                "lambda:InvokeFunction"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "${var.codestar_connection_arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:StartBuild",
                "codebuild:BatchGetBuilds"
            ],
            "Resource": "${aws_codebuild_project.main.arn}"
        }
    ]
}
POLICY
}

resource "aws_codepipeline" "main" {
  name                          = "${var.basic_name}-codepipeline"
  role_arn                      = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location                    = var.artifact_bucket_name
    type                        = "S3"
  }
  
  stage {
    name = "Source"

    action {
      name                      = "Source"
      category                  = "Source"
      owner                     = "AWS"
      provider                  = "CodeStarSourceConnection"
      version                   = "1"
      output_artifacts          = ["MyApp"]

      configuration             = {
        ConnectionArn           = var.codestar_connection_arn
        FullRepositoryId        = var.full_repo_id
        BranchName              = var.repo_branch
        OutputArtifactFormat    = "CODE_ZIP"
      }
    }
  }
  
  stage {
    name = "Build"

    action {
      name                      = "Build"
      category                  = "Build"
      owner                     = "AWS"
      provider                  = "CodeBuild"
      version                   = "1"
      input_artifacts           = ["MyApp"]
      output_artifacts          = ["BuildOutput"]

      configuration             = {
        ProjectName             = aws_codebuild_project.main.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name                      = "Deploy"
      category                  = "Deploy"
      owner                     = "AWS"
      provider                  = "ECS"
      input_artifacts           = ["BuildOutput"]
      version                   = "1"

      configuration = {
        ClusterName              = var.ecs_cluster_name
        ServiceName              = var.ecs_service_name
      }
    }
  }

  depends_on = [
    time_sleep.wait_iam_policy,
  ]
}

resource "time_sleep" "wait_iam_policy" {
  depends_on = [
    aws_iam_role_policy.backend_codepipeline_role_policy,
  ]
  create_duration = "15s"
}
