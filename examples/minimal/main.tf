# ============================================================================
# Minimal AWS Connect Example
# ============================================================================
# This example creates a basic Connect instance with minimal configuration
# Suitable for: Testing, development, proof of concept
# ============================================================================

# ============================================================================
# Provider Configuration
# ============================================================================

provider "aws" {
  region = var.aws_region
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# S3 Bucket for Call Recordings (Optional but Recommended)
# ============================================================================

resource "aws_s3_bucket" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = "${var.instance_alias}-recordings-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name    = "${var.instance_alias}-recordings"
      Purpose = "Connect call recordings"
    }
  )
}

# Block public access
resource "aws_s3_bucket_public_access_block" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = aws_s3_bucket.recordings[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = aws_s3_bucket.recordings[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = aws_s3_bucket.recordings[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = aws_s3_bucket.recordings[0].id

  rule {
    id     = "delete-old-recordings"
    status = "Enabled"

    expiration {
      days = var.recordings_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# Bucket policy to allow Connect
resource "aws_s3_bucket_policy" "recordings" {
  count = var.enable_call_recordings ? 1 : 0

  bucket = aws_s3_bucket.recordings[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowConnectToWriteRecordings"
        Effect = "Allow"
        Principal = {
          Service = "connect.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.recordings[0].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowConnectToGetBucketLocation"
        Effect = "Allow"
        Principal = {
          Service = "connect.amazonaws.com"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketAcl"
        ]
        Resource = aws_s3_bucket.recordings[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# ============================================================================
# Connect Instance
# ============================================================================

module "connect_instance" {
  source = "../../modules/connect-instance"

  # Basic configuration
  instance_alias           = var.instance_alias
  identity_management_type = "CONNECT_MANAGED"

  # Enable inbound calls only (most common for support centers)
  inbound_calls_enabled  = true
  outbound_calls_enabled = false

  # Enable logging for debugging
  contact_flow_logs_enabled = true

  # Disable Contact Lens to save costs (enable in production if needed)
  contact_lens_enabled = false

  # Storage configuration (if call recordings enabled)
  storage_config = var.enable_call_recordings ? {
    call_recordings = {
      storage_type = "S3"
      s3_config = {
        bucket_name   = aws_s3_bucket.recordings[0].id
        bucket_prefix = "recordings/"
        encryption_config = {
          encryption_type = "AES256"
        }
      }
    }
  } : {}

  # Tags
  tags = var.tags
}