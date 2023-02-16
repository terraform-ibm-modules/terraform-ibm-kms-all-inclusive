##############################################################################
# Outputs
##############################################################################

output "key_protect_guid" {
  description = "Key Protect GUID"
  value       = local.key_protect_guid
}

output "key_protect_name" {
  description = "Key Protect Name"
  value       = length(module.key_protect) > 0 ? module.key_protect[0].key_protect_name : null
}

output "key_protect_instance_policies" {
  description = "Instance Polices of the Key Protect instance"
  value       = length(module.key_protect) > 0 ? module.key_protect.key_protect_instance_policies : null
}

output "key_rings" {
  description = "IDs of new Key Rings created by the module"
  value       = module.key_protect_key_rings
}

output "keys" {
  description = "IDs of new Keys created by the module"
  value       = module.key_protect_keys
}

output "existing_key_ring_keys" {
  description = "IDs of Keys created by the module in existing Key Rings"
  value       = module.existing_key_ring_keys
}
