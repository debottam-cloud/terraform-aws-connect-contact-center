# ============================================================================
# Required Variables
# ============================================================================

variable "instance_alias" {
  description = <<-EOT
    The alias for the AWS Connect instance.
    This becomes part of the instance URL: https://[instance_alias].my.connect.aws
    
    Constraints:
    - Must be 1-62 characters
    - Lowercase letters, numbers, and hyphens only
    - Must start with a letter
    - Cannot end with a hyphen
    - Must be unique within your AWS account
    
    Example: "customer-support"
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,60}[a-z0-9]$", var.instance_alias))
    error_message = "instance_alias must be 1-62 characters, start with a letter, contain only lowercase letters, numbers, and hyphens, and not end with a hyphen."
  }
}

# ============================================================================
# Identity Management
# ============================================================================

variable "identity_management_type" {
  description = <<-EOT
    Specifies the identity management type for the Connect instance.
    
    Options:
    - CONNECT_MANAGED: Connect manages user identities (simplest setup)
    - SAML: Use SAML 2.0-based authentication (enterprise SSO)
    - EXISTING_DIRECTORY: Use AWS Directory Service
    
    Default: CONNECT_MANAGED
  EOT
  type        = string
  default     = "CONNECT_MANAGED"

  validation {
    condition     = contains(["CONNECT_MANAGED", "SAML", "EXISTING_DIRECTORY"], var.identity_management_type)
    error_message = "identity_management_type must be one of: CONNECT_MANAGED, SAML, EXISTING_DIRECTORY."
  }
}

variable "directory_id" {
  description = <<-EOT
    AWS Directory Service directory ID.
    Required when identity_management_type = "EXISTING_DIRECTORY"
    
    The directory must be:
    - In the same region as the Connect instance
    - Microsoft AD, AD Connector, or Simple AD
    
    Example: "d-1234567890"
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.directory_id == null || can(regex("^d-[0-9a-f]{10}$", var.directory_id))
    error_message = "directory_id must be in the format 'd-xxxxxxxxxx' where x is a hexadecimal digit."
  }
}

variable "saml_metadata_url" {
  description = <<-EOT
    SAML metadata URL for SAML-based authentication.
    Required when identity_management_type = "SAML"
    
    This URL points to your identity provider's SAML metadata document.
    
    Example: "https://portal.sso.us-east-1.amazonaws.com/saml/metadata/..."
  EOT
  type        = string
  default     = null
}

# ============================================================================
# Instance Configuration
# ============================================================================

variable "inbound_calls_enabled" {
  description = <<-EOT
    Whether inbound calls are enabled for the Connect instance.
    Set to false only for outbound-only contact centers.
    
    Default: true
  EOT
  type        = bool
  default     = true
}

variable "outbound_calls_enabled" {
  description = <<-EOT
    Whether outbound calls are enabled for the Connect instance.
    Required for outbound campaigns (preview, progressive, predictive).
    
    Default: false
  EOT
  type        = bool
  default     = false
}

variable "contact_flow_logs_enabled" {
  description = <<-EOT
    Whether contact flow logs are enabled.
    Logs are sent to CloudWatch Logs under /aws/connect/[instance_alias]
    
    Recommended: true for production (helps with debugging)
    Default: true
  EOT
  type        = bool
  default     = true
}

variable "contact_lens_enabled" {
  description = <<-EOT
    Whether to enable Contact Lens for Amazon Connect.
    
    Features:
    - Real-time and post-call analytics
    - Sentiment analysis
    - Call categorization
    - Supervisor alerts
    
    Cost: Additional charges apply (~$0.015/min analyzed)
    Default: false
  EOT
  type        = bool
  default     = false
}

variable "early_media_enabled" {
  description = <<-EOT
    Whether early media is enabled.
    Allows callers to hear audio before the call is answered.
    
    Use cases:
    - Playing prompts while contacting agents
    - Ring-back tones
    - Music on hold during transfer
    
    Default: true
  EOT
  type        = bool
  default     = true
}

variable "auto_resolve_best_voices" {
  description = <<-EOT
    Whether Amazon Connect automatically resolves the best voices for TTS.
    When enabled, Connect uses the most natural-sounding voices available.
    
    Default: true
  EOT
  type        = bool
  default     = true
}

# ============================================================================
# Storage Configuration
# ============================================================================

variable "storage_config" {
  description = <<-EOT
    Storage configuration for recordings, transcripts, reports, and attachments.
    
    Structure:
    {
      call_recordings = {
        storage_type = "S3"  # or "KINESIS_VIDEO_STREAM"
        s3_config = {
          bucket_name   = "my-recordings"
          bucket_prefix = "recordings/"  # Optional
          encryption_config = {          # Optional
            encryption_type = "KMS"      # or "AES256"
            key_id          = "arn:..."  # Required if KMS
          }
        }
      }
      
      chat_transcripts = {
        storage_type = "S3"
        s3_config = {
          bucket_name   = "my-transcripts"
          bucket_prefix = "transcripts/"
        }
      }
      
      scheduled_reports = {
        storage_type = "S3"
        s3_config = {
          bucket_name   = "my-reports"
          bucket_prefix = "reports/"
        }
      }
      
      attachments = {
        storage_type = "S3"
        s3_config = {
          bucket_name   = "my-attachments"
          bucket_prefix = "attachments/"
        }
      }
      
      media_streams = {
        storage_type = "KINESIS_VIDEO_STREAM"
        kinesis_config = {
          prefix                 = "media-streams"
          retention_period_hours = 24
          encryption_config = {
            encryption_type = "KMS"
            key_id          = "arn:..."
          }
        }
      }
    }
    
    Note: S3 buckets must be in the same region as the Connect instance.
          Create buckets separately before applying this module.
  EOT
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      for storage_type, config in var.storage_config : (
        contains(["call_recordings", "chat_transcripts", "scheduled_reports", "attachments", "media_streams"], storage_type)
      )
    ])
    error_message = "storage_config keys must be one of: call_recordings, chat_transcripts, scheduled_reports, attachments, media_streams."
  }
}

# ============================================================================
# Tagging
# ============================================================================

variable "tags" {
  description = <<-EOT
    Tags to apply to the Connect instance and related resources.
    
    Recommended tags:
    - Environment: dev, staging, prod
    - ManagedBy: Terraform
    - Project: project-name
    - CostCenter: cost-center-id
    
    Example:
    {
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "CustomerSupport"
    }
  EOT
  type        = map(string)
  default     = {}
}