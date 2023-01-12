# S3 bucket creation

resource "aws_s3_bucket" "console_access_logs" {
  bucket = "${data.aws_iam_account_alias.current.account_alias}-console-alb-access-logs"
  acl    = "log-delivery-write"
  policy = templatefile("alb_policy.json",{account_id = data.aws_caller_identity.current.account_id, bucket_name="${data.aws_iam_account_alias.current.account_alias}-console-alb-access-logs"})

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "transition-to-glacier"
    enabled = true
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
  lifecycle_rule {
    id      = "delete-objects"
    enabled = true
    expiration {
      days = 365
    }
  }
}
