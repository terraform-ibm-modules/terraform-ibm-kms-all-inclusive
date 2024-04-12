##############################################################################
# Outputs
##############################################################################

output "kms_guid" {
  description = "KMS GUID"
  value       = local.kms_guid
}

output "key_protect_id" {
  description = "Key Protect service instance ID when an instance is created, otherwise null"
  value       = can(module.key_protect[0].key_protect_id) ? module.key_protect[0].key_protect_id : null
}

output "key_protect_name" {
  description = "Key Protect Name"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_name : null
}

# The ID is the CRN, output ID as CRN until the base module is updated
output "key_protect_crn" {
  description = "Key Protect service instance CRN when an instance is created, otherwise null"
  value       = can(module.key_protect[0].key_protect_id) ? module.key_protect[0].key_protect_id : null
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

output "kp_private_endpoint" {
  description = "Key Protect instance private endpoint URL"
  value       = var.create_key_protect_instance ? module.key_protect[0].kp_private_endpoint : null
}

output "kp_public_endpoint" {
  description = "Key Protect instance public endpoint URL"
  value       = var.create_key_protect_instance ? module.key_protect[0].kp_public_endpoint : null
}
