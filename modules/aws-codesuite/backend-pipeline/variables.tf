variable "basic_name" {
  type        = string
  description = "The basis (prefix) for naming resources"
}

variable "codebuild_timeout" {
  type        = number
  default     = 60
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
}

variable "codebuild_queued_timeout" {
  type        = number
  default     = 480
  description = "How long in minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out."
}

variable "codebuild_tags" {
  type        = map(string)
  default     = {}
  description = "Mapping of tags for CodeBuild project"
}

variable "aws_region" {
  type        = string
  description = "AWS region as value for backend's build project's environment variable AWS_DEFAULT_REGION"
  validation {
    condition     = can(index(["eu-north-1", "ap-south-1", "eu-west-3",
                              "eu-west-2", "eu-west-1", "ap-northeast-2",
                              "ap-northeast-1", "sa-east-1", "ca-central-1",
                              "ap-southeast-1", "ap-southeast-2", "eu-central-1",
                              "us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.aws_region))
    error_message = "The aws_region value must be a valid AWS region (eu-north-1, us-west-2, etc.)."
  }
}

variable "cron_ecr_repo_name" {
  type        = string
  default     = ""
  description = "Value for backend's build project's environment variable IMAGE_REPO_NAME_CRON"
}

variable "app_ecr_repo_name" {
  type        = string
  default     = ""
  description = "Value for backend's build project's environment variable IMAGE_REPO_NAME_PHP_FPM"
}

variable "proxy_ecr_repo_name" {
  type        = string
  default     = ""
  description = "Value for backend's build project's environment variable IMAGE_REPO_NAME_NGINX"
}

variable "ecr_repo_arn" {
  type        = string
  description = "The ARN of any of ECR repo(es) where CodeBuild project must have permissions to push built docker images to (a suffix will be truncated and access to all backend service ECR repos will be greanted)."
}

variable "artifact_bucket_arn" {
  type        = string
  description = "ARN of the artifacts S3 bucket"
}

variable "artifact_bucket_name" {
  type        = string
  description = "The name of the artifacts S3 bucket"
}

variable "codebuild_ssm_params_path_arn" {
  type        = string
  description = "ARN of path to SSM parameters used by CodeBuild projects"
}

variable "kms_key" {
  type        = string
  description = "ARN of KMS key to decrypt SecureString SSM parameters"
}

variable "kms_alias" {
  type        = string
  description = "ARN of alias for KMS key to decrypt SecureString SSM parameters"
}





variable "codestar_connection_arn" {
  type        = string
  description = "ARN of CodeStar Connection for the Source stage of the pipeline."
}

variable "repo_branch" {
  type        = string
  description = "The name of the branch of the repo for Source stage of the pipeline."
}

variable "full_repo_id" {
  type        = string
  description = "The owner and name of the repository where source changes are to be detected."
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster for Deploy stage of the pipeline."
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service for Deploy stage of the pipeline."
}