# S3 bucket creation

resource "aws_s3_bucket" "access_logging" {
  bucket = upper("${data.aws_iam_account_alias.current.account_alias}-access-logging")
  acl    = "log-delivery-write"

# Enabling encryption for the bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

# Enable versioning of the objects

  versioning {
    enabled = true
  }

# Enable the lifecycle rule to move the objects to different storage class

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
