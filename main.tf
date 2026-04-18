# ============================================================================
# AWS Connect Contact Center Module
# ============================================================================
# Root module that orchestrates all submodules
# ============================================================================

# ============================================================================
# Connect Instance Module
# ============================================================================

module "connect_instance" {
  source = "./modules/connect-instance"

  # Instance configuration
  instance_alias           = var.instance_alias
  identity_management_type = var.identity_management_type
  inbound_calls_enabled    = var.inbound_calls_enabled
  outbound_calls_enabled   = var.outbound_calls_enabled

  # Optional features
  contact_flow_logs_enabled = var.contact_flow_logs_enabled
  contact_lens_enabled      = var.contact_lens_enabled
  early_media_enabled       = var.early_media_enabled
  auto_resolve_best_voices  = var.auto_resolve_best_voices

  # Storage configuration
  storage_config = var.storage_config

  # Directory integration (for EXISTING_DIRECTORY type)
  directory_id = var.directory_id

  # SAML URL (for SAML type)
  saml_metadata_url = var.saml_metadata_url

  # Tags
  tags = var.tags
}

# ============================================================================
# Placeholder for future modules (v0.2.0+)
# ============================================================================

# module "hours_of_operation" {
#   source = "./modules/hours-of-operation"
#   
#   instance_id = module.connect_instance.instance_id
#   hours       = var.hours_of_operation
#   
#   count = length(var.hours_of_operation) > 0 ? 1 : 0
# }

# module "queues" {
#   source = "./modules/queues"
#   
#   instance_id            = module.connect_instance.instance_id
#   queues                 = var.queues
#   hours_of_operation_ids = module.hours_of_operation[0].hours_of_operation_ids
#   
#   count      = length(var.queues) > 0 ? 1 : 0
#   depends_on = [module.hours_of_operation]
# }

# module "contact_flows" {
#   source = "./modules/contact-flows"
#   
#   instance_id = module.connect_instance.instance_id
#   flows       = var.contact_flows
#   
#   count      = length(var.contact_flows) > 0 ? 1 : 0
#   depends_on = [module.queues]
# }