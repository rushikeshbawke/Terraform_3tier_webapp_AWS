data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------ It helps make backends and resource names account-aware,
# ------ avoids hardcoding, and ensures portability across multiple AWS accounts.

resource "random_id" "suffix" {
  byte_length = 3
}

# ------ random_id is Terraform's way of giving you a unique,
# ------ reproducible random string/number to use in resource names or identifiers.

# ------- S3 Bucket for Flow Logs ------

resource "aws_s3_bucket" "flow_logs" {
  bucket = "flow-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${random_id.suffix.hex}"
  
  tags = {
    Name = "flow-logs-bucket"
  }
}

resource "aws_s3_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        sid = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.flow_logs.arn}/*"
        condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
      {
        sid = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.flow_logs.arn
      }
    ]
  })
}