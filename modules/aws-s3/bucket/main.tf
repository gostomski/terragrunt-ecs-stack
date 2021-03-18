#data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "main" {
  bucket                  = var.name
  acl                     = var.allow_log_delivery_write ? "log-delivery-write" : "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  dynamic "cors_rule" {
    for_each              = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers     = cors_rule.value.allowed_headers
      allowed_methods     = cors_rule.value.allowed_methods
      allowed_origins     = cors_rule.value.allowed_origins
      expose_headers      = cors_rule.value.expose_headers
      max_age_seconds     = cors_rule.value.max_age_seconds
    }
  }

  tags                    = var.tags
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  count                   = var.block_all_public_access ? 1 : 0
}