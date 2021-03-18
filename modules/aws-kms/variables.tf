variable "namespace" {
  type        = string
  default     = null
  description = "Namespace, which could be organization name or abbreviation."
}

variable "env" {
  type        = string
  default     = null
  description = "Environment name."
}

variable "aws_region" {
  type        = string
  description = "AWS region where to allow AWS CloudWatch Logs to use the key from."
  validation {
    condition     = can(index(["eu-north-1", "ap-south-1", "eu-west-3",
                              "eu-west-2", "eu-west-1", "ap-northeast-2",
                              "ap-northeast-1", "sa-east-1", "ca-central-1",
                              "ap-southeast-1", "ap-southeast-2", "eu-central-1",
                              "us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.aws_region))
    error_message = "The aws_region value must be a valid AWS region (eu-north-1, us-west-2, etc.)."
  }
}