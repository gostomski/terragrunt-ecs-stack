data "aws_caller_identity" "current" {}

module "key" {
  source                  = "github.com/cloudposse/terraform-aws-kms-key.git?ref=0.7.0"
  namespace               = var.namespace
  stage                   = var.env
  name                    = "kms-key"
  description             = "KMS key for ${var.namespace}-${var.env}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kms:*",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Resource": "*",
      "Sid": "Enable IAM User Permissions"
    },
    {
      "Action": [
        "kms:Decrypt*",
        "kms:Describe*",
        "kms:Encrypt*",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*"
      ],
      "Effect": "Allow",
      "Principal": {
        "Service":  "logs.${var.aws_region}.amazonaws.com"
      },
      "Resource": "*",
      "Sid": "Allow logs KMS access"
    }
  ]
}
EOF
}