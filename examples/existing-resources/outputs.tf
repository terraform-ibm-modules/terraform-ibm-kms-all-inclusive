##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "key_protect_id" {
  description = "Key Protect service instance ID"
  value       = module.existing_key_protect.key_protect_id
}

output "key_protect_guid" {
  description = "Key Protect GUID"
  value       = module.key_protect_all_inclusive.key_protect_guid
}

output "key_protect_name" {
  description = "Key Protect Name"
  value       = module.key_protect_all_inclusive.key_protect_name
}

output "key_protect_instance_policies" {
  description = "Instance Polices of the Key Protect instance"
  value       = module.key_protect_all_inclusive.key_protect_instance_policies
}

output "key_rings" {
  description = "IDs of Key Rings created by the module"
  value       = module.key_protect_all_inclusive.key_rings
}

output "keys" {
  description = "Keys created by the module"
  value       = module.key_protect_all_inclusive.keys
}

output "existing_key_ring_keys" {
  description = "Keys created by the module in existing Key Rings"
  value       = module.key_protect_all_inclusive.existing_key_ring_keys
}
