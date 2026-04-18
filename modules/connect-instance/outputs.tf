# ============================================================================
# Connect Instance Outputs
# ============================================================================

output "instance_id" {
  description = "The identifier of the Connect instance"
  value       = aws_connect_instance.this.id
}

output "instance_arn" {
  description = "The ARN of the Connect instance"
  value       = aws_connect_instance.this.arn
}

output "instance_alias" {
  description = "The alias of the Connect instance"
  value       = aws_connect_instance.this.instance_alias
}

output "instance_url" {
  description = "The URL to access the Connect instance admin interface"
  value       = "https://${aws_connect_instance.this.instance_alias}.my.connect.aws"
}

output "instance_status" {
  description = "The state of the instance (CREATION_IN_PROGRESS, ACTIVE, CREATION_FAILED)"
  value       = aws_connect_instance.this.status
}

output "service_role_arn" {
  description = "The service-linked role ARN associated with the instance"
  value       = aws_connect_instance.this.service_role
}

output "created_time" {
  description = "The timestamp when the instance was created"
  value       = aws_connect_instance.this.created_time
}

output "identity_management_type" {
  description = "The identity management type configured for the instance"
  value       = aws_connect_instance.this.identity_management_type
}

# ============================================================================
# Storage Configuration Outputs
# ============================================================================

output "storage_config" {
  description = "Storage configuration details for the Connect instance"
  value = {
    call_recordings = try({
      id            = aws_connect_instance_storage_config.call_recordings[0].id
      resource_type = aws_connect_instance_storage_config.call_recordings[0].resource_type
      storage_type  = aws_connect_instance_storage_config.call_recordings[0].storage_config[0].storage_type
    }, null)

    chat_transcripts = try({
      id            = aws_connect_instance_storage_config.chat_transcripts[0].id
      resource_type = aws_connect_instance_storage_config.chat_transcripts[0].resource_type
      storage_type  = aws_connect_instance_storage_config.chat_transcripts[0].storage_config[0].storage_type
    }, null)

    scheduled_reports = try({
      id            = aws_connect_instance_storage_config.scheduled_reports[0].id
      resource_type = aws_connect_instance_storage_config.scheduled_reports[0].resource_type
      storage_type  = aws_connect_instance_storage_config.scheduled_reports[0].storage_config[0].storage_type
    }, null)

    attachments = try({
      id            = aws_connect_instance_storage_config.attachments[0].id
      resource_type = aws_connect_instance_storage_config.attachments[0].resource_type
      storage_type  = aws_connect_instance_storage_config.attachments[0].storage_config[0].storage_type
    }, null)

    media_streams = try({
      id            = aws_connect_instance_storage_config.media_streams[0].id
      resource_type = aws_connect_instance_storage_config.media_streams[0].resource_type
      storage_type  = aws_connect_instance_storage_config.media_streams[0].storage_config[0].storage_type
    }, null)
  }
}

# ============================================================================
# Feature Flags
# ============================================================================

output "features_enabled" {
  description = "Features enabled on the Connect instance"
  value = {
    inbound_calls_enabled     = var.inbound_calls_enabled
    outbound_calls_enabled    = var.outbound_calls_enabled
    contact_flow_logs_enabled = var.contact_flow_logs_enabled
    contact_lens_enabled      = var.contact_lens_enabled
    early_media_enabled       = var.early_media_enabled
    auto_resolve_best_voices  = var.auto_resolve_best_voices
  }
}

# ============================================================================
# Useful Connection Information
# ============================================================================

output "connection_info" {
  description = "Connection information for agents and administrators"
  value = {
    admin_url      = "https://${aws_connect_instance.this.instance_alias}.my.connect.aws"
    ccp_url        = "https://${aws_connect_instance.this.instance_alias}.my.connect.aws/ccp-v2/"
    instance_alias = aws_connect_instance.this.instance_alias
    instance_id    = aws_connect_instance.this.id
    region         = data.aws_region.current.name
  }
}