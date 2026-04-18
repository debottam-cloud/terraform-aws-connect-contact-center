# ============================================================================
# AWS Connect Instance Module
# ============================================================================
# Creates and configures an AWS Connect instance with storage and IAM roles
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# ============================================================================
# Connect Instance
# ============================================================================

resource "aws_connect_instance" "this" {
  # Required attributes
  instance_alias           = var.instance_alias
  identity_management_type = var.identity_management_type

  # Optional attributes
  inbound_calls_enabled  = var.inbound_calls_enabled
  outbound_calls_enabled = var.outbound_calls_enabled

  # Instance attributes
  dynamic "attributes" {
    for_each = var.contact_flow_logs_enabled || var.contact_lens_enabled || var.early_media_enabled || var.auto_resolve_best_voices ? [1] : []

    content {
      contact_flow_logs_enabled = var.contact_flow_logs_enabled
      contact_lens_enabled      = var.contact_lens_enabled
      early_media_enabled       = var.early_media_enabled
      auto_resolve_best_voices  = var.auto_resolve_best_voices
    }
  }

  # Directory integration (for EXISTING_DIRECTORY)
  directory_id = var.identity_management_type == "EXISTING_DIRECTORY" ? var.directory_id : null

  # Tags
  tags = merge(
    var.tags,
    {
      Name      = var.instance_alias
      ManagedBy = "Terraform"
      Module    = "connect-instance"
    }
  )
}

# ============================================================================
# Storage Configuration
# ============================================================================

# Call Recordings Storage
resource "aws_connect_instance_storage_config" "call_recordings" {
  count = try(var.storage_config.call_recordings, null) != null ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "CALL_RECORDINGS"

  storage_config {
    storage_type = try(var.storage_config.call_recordings.storage_type, "S3")

    # S3 Configuration
    dynamic "s3_config" {
      for_each = try(var.storage_config.call_recordings.storage_type, "S3") == "S3" ? [1] : []

      content {
        bucket_name   = var.storage_config.call_recordings.s3_config.bucket_name
        bucket_prefix = try(var.storage_config.call_recordings.s3_config.bucket_prefix, "call-recordings/")

        # Encryption configuration
        dynamic "encryption_config" {
          for_each = try(var.storage_config.call_recordings.s3_config.encryption_config, null) != null ? [1] : []

          content {
            encryption_type = var.storage_config.call_recordings.s3_config.encryption_config.encryption_type
            key_id          = try(var.storage_config.call_recordings.s3_config.encryption_config.key_id, null)
          }
        }
      }
    }

    # Kinesis Video Stream Configuration
    dynamic "kinesis_video_stream_config" {
      for_each = try(var.storage_config.call_recordings.storage_type, "") == "KINESIS_VIDEO_STREAM" ? [1] : []

      content {
        prefix = try(var.storage_config.call_recordings.kinesis_config.prefix, "")

        retention_period_hours = try(
          var.storage_config.call_recordings.kinesis_config.retention_period_hours,
          87600 # 10 years default
        )

        dynamic "encryption_config" {
          for_each = try(var.storage_config.call_recordings.kinesis_config.encryption_config, null) != null ? [1] : []

          content {
            encryption_type = var.storage_config.call_recordings.kinesis_config.encryption_config.encryption_type
            key_id          = var.storage_config.call_recordings.kinesis_config.encryption_config.key_id
          }
        }
      }
    }
  }
}

# Chat Transcripts Storage
resource "aws_connect_instance_storage_config" "chat_transcripts" {
  count = try(var.storage_config.chat_transcripts, null) != null ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "CHAT_TRANSCRIPTS"

  storage_config {
    storage_type = try(var.storage_config.chat_transcripts.storage_type, "S3")

    dynamic "s3_config" {
      for_each = try(var.storage_config.chat_transcripts.storage_type, "S3") == "S3" ? [1] : []

      content {
        bucket_name   = var.storage_config.chat_transcripts.s3_config.bucket_name
        bucket_prefix = try(var.storage_config.chat_transcripts.s3_config.bucket_prefix, "chat-transcripts/")

        dynamic "encryption_config" {
          for_each = try(var.storage_config.chat_transcripts.s3_config.encryption_config, null) != null ? [1] : []

          content {
            encryption_type = var.storage_config.chat_transcripts.s3_config.encryption_config.encryption_type
            key_id          = try(var.storage_config.chat_transcripts.s3_config.encryption_config.key_id, null)
          }
        }
      }
    }
  }
}

# Scheduled Reports Storage
resource "aws_connect_instance_storage_config" "scheduled_reports" {
  count = try(var.storage_config.scheduled_reports, null) != null ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "SCHEDULED_REPORTS"

  storage_config {
    storage_type = try(var.storage_config.scheduled_reports.storage_type, "S3")

    dynamic "s3_config" {
      for_each = try(var.storage_config.scheduled_reports.storage_type, "S3") == "S3" ? [1] : []

      content {
        bucket_name   = var.storage_config.scheduled_reports.s3_config.bucket_name
        bucket_prefix = try(var.storage_config.scheduled_reports.s3_config.bucket_prefix, "scheduled-reports/")

        dynamic "encryption_config" {
          for_each = try(var.storage_config.scheduled_reports.s3_config.encryption_config, null) != null ? [1] : []

          content {
            encryption_type = var.storage_config.scheduled_reports.s3_config.encryption_config.encryption_type
            key_id          = try(var.storage_config.scheduled_reports.s3_config.encryption_config.key_id, null)
          }
        }
      }
    }
  }
}

# Attachments Storage
resource "aws_connect_instance_storage_config" "attachments" {
  count = try(var.storage_config.attachments, null) != null ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "ATTACHMENTS"

  storage_config {
    storage_type = try(var.storage_config.attachments.storage_type, "S3")

    dynamic "s3_config" {
      for_each = try(var.storage_config.attachments.storage_type, "S3") == "S3" ? [1] : []

      content {
        bucket_name   = var.storage_config.attachments.s3_config.bucket_name
        bucket_prefix = try(var.storage_config.attachments.s3_config.bucket_prefix, "attachments/")

        dynamic "encryption_config" {
          for_each = try(var.storage_config.attachments.s3_config.encryption_config, null) != null ? [1] : []

          content {
            encryption_type = var.storage_config.attachments.s3_config.encryption_config.encryption_type
            key_id          = try(var.storage_config.attachments.s3_config.encryption_config.key_id, null)
          }
        }
      }
    }
  }
}

# Media Streams Storage
resource "aws_connect_instance_storage_config" "media_streams" {
  count = try(var.storage_config.media_streams, null) != null ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "MEDIA_STREAMS"

  storage_config {
    storage_type = "KINESIS_VIDEO_STREAM"

    kinesis_video_stream_config {
      prefix                 = try(var.storage_config.media_streams.kinesis_config.prefix, "")
      retention_period_hours = try(var.storage_config.media_streams.kinesis_config.retention_period_hours, 0)

      dynamic "encryption_config" {
        for_each = try(var.storage_config.media_streams.kinesis_config.encryption_config, null) != null ? [1] : []

        content {
          encryption_type = var.storage_config.media_streams.kinesis_config.encryption_config.encryption_type
          key_id          = var.storage_config.media_streams.kinesis_config.encryption_config.key_id
        }
      }
    }
  }
}