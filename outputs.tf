##############################################################################
# Outputs
##############################################################################

output "kms_guid" {
  description = "Key Protect GUID"
  value       = local.kms_guid
}

output "kms_account_id" {
  description = "The account ID of the Key Protect instance."
  value       = local.kms_account_id
}

output "key_protect_id" {
  description = "Key Protect service instance ID when an instance is created, otherwise the value is `null`."
  value       = can(module.key_protect[0].key_protect_id) ? module.key_protect[0].key_protect_id : null
}

output "key_protect_name" {
  description = "Key Protect name"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_name : null
}

output "key_protect_crn" {
  description = "Key Protect service instance CRN when an instance is created, otherwise the value is `null`."
  value       = can(module.key_protect[0].key_protect_crn) ? module.key_protect[0].key_protect_crn : null
}

output "key_protect_instance_policies" {
  description = "Instance polices for the Key Protect instance"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_instance_policies : null
}

output "key_rings" {
  description = "Key rings that are created"
  value       = module.kms_key_rings
}

output "keys" {
  description = "Keys that are created"
  value       = merge(module.kms_keys, module.existing_key_ring_keys)
}

output "kms_private_endpoint" {
  description = "Key Protect instance private endpoint URL"
  value       = local.kms_private_endpoint
}

output "kms_public_endpoint" {
  description = "Key Protect instance public endpoint URL"
  value       = local.kms_public_endpoint
}

output "cbr_rule_ids" {
  description = "Context-based restriction rule IDs to restrict access to the Key Protect instance"
  value       = length(module.key_protect[*]) > 0 ? module.key_protect[0].cbr_rule_ids : null
}
