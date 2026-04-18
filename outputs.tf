# ============================================================================
# Connect Instance Outputs
# ============================================================================

output "instance_id" {
  description = "The identifier of the Connect instance"
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

output "instance_url" {
  description = "The URL to access the Connect instance"
  value       = module.connect_instance.instance_url
}

output "instance_status" {
  description = "The status of the Connect instance"
  value       = module.connect_instance.instance_status
}

output "service_role_arn" {
  description = "The ARN of the service role created for the Connect instance"
  value       = module.connect_instance.service_role_arn
}

output "created_time" {
  description = "The timestamp when the instance was created"
  value       = module.connect_instance.created_time
}

# ============================================================================
# Storage Configuration Outputs
# ============================================================================

output "storage_config" {
  description = "Storage configuration for the Connect instance"
  value       = module.connect_instance.storage_config
  sensitive   = false
}

# ============================================================================
# Future Module Outputs (v0.2.0+)
# ============================================================================

# output "hours_of_operation" {
#   description = "Map of hours of operation names to their IDs"
#   value       = try(module.hours_of_operation[0].hours_of_operation_map, {})
# }

# output "queue_ids" {
#   description = "Map of queue names to their IDs"
#   value       = try(module.queues[0].queue_map, {})
# }

# output "contact_flow_ids" {
#   description = "Map of contact flow names to their IDs"
#   value       = try(module.contact_flows[0].flow_map, {})
# }