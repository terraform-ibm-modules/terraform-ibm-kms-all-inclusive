##############################################################################
# Outputs
##############################################################################

output "kms_guid" {
  description = "KMS GUID"
  value       = local.kms_guid
}

output "kms_account_id" {
  description = "The account ID of the KMS instance."
  value       = local.kms_account_id
}

output "key_protect_id" {
  description = "Key Protect service instance ID when an instance is created, otherwise null"
  value       = can(module.key_protect[0].key_protect_id) ? module.key_protect[0].key_protect_id : null
}

output "key_protect_name" {
  description = "Key Protect Name"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_name : null
}

output "key_protect_crn" {
  description = "Key Protect service instance CRN when an instance is created, otherwise null"
  value       = can(module.key_protect[0].key_protect_crn) ? module.key_protect[0].key_protect_crn : null
}

output "key_protect_instance_policies" {
  description = "Instance Polices of the Key Protect instance"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_instance_policies : null
}

output "key_rings" {
  description = "IDs of new Key Rings created by the module"
  value       = module.kms_key_rings
}

output "keys" {
  description = "IDs of new Keys created by the module"
  value       = merge(module.kms_keys, module.existing_key_ring_keys)
}

output "kms_private_endpoint" {
  description = "Key Management Service instance private endpoint URL"
  value       = local.kms_private_endpoint
}

output "kms_public_endpoint" {
  description = "Key Management Service instance public endpoint URL"
  value       = local.kms_public_endpoint
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict Key Protect"
  value       = length(module.key_protect[*]) > 0 ? module.key_protect[0].cbr_rule_ids : null
}
