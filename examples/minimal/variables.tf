# ============================================================================
# Required Variables
# ============================================================================

variable "instance_alias" {
  description = "The alias for the Connect instance (must be unique in your AWS account)"
  type        = string
  default     = "minimal-example"
}

# ============================================================================
# Optional Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region where the Connect instance will be created"
  type        = string
  default     = "us-east-1"
}

variable "enable_call_recordings" {
  description = "Whether to enable call recordings and create S3 bucket"
  type        = bool
  default     = true
}

variable "recordings_retention_days" {
  description = "Number of days to retain call recordings before automatic deletion"
  type        = number
  default     = 90

  validation {
    condition     = var.recordings_retention_days >= 1 && var.recordings_retention_days <= 3650
    error_message = "Retention days must be between 1 and 3650 (10 years)."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Example     = "minimal"
    ManagedBy   = "Terraform"
  }
}