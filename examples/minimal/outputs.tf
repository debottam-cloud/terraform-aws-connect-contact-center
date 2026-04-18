# ============================================================================
# Connect Instance Outputs
# ============================================================================

output "instance_id" {
  description = "The ID of the Connect instance"
  value       = module.connect_instance.instance_id
}

output "instance_arn" {
  description = "The ARN of the Connect instance"
  value       = module.connect_instance.instance_arn
}

output "instance_alias" {
  description = "The alias of the Connect instance"
  value       = module.connect_instance.instance_alias
}

output "admin_url" {
  description = "URL to access the Connect admin interface"
  value       = module.connect_instance.instance_url
}

output "ccp_url" {
  description = "URL for the Contact Control Panel (CCP) for agents"
  value       = module.connect_instance.connection_info.ccp_url
}

output "instance_status" {
  description = "The status of the Connect instance"
  value       = module.connect_instance.instance_status
}

# ============================================================================
# S3 Bucket Outputs
# ============================================================================

output "recordings_bucket_name" {
  description = "Name of the S3 bucket for call recordings"
  value       = var.enable_call_recordings ? aws_s3_bucket.recordings[0].id : null
}

output "recordings_bucket_arn" {
  description = "ARN of the S3 bucket for call recordings"
  value       = var.enable_call_recordings ? aws_s3_bucket.recordings[0].arn : null
}

# ============================================================================
# Connection Information
# ============================================================================

output "connection_info" {
  description = "Complete connection information for the Contact Center"
  value = {
    admin_url      = module.connect_instance.instance_url
    ccp_url        = module.connect_instance.connection_info.ccp_url
    instance_id    = module.connect_instance.instance_id
    instance_alias = module.connect_instance.instance_alias
    region         = module.connect_instance.connection_info.region
  }
}