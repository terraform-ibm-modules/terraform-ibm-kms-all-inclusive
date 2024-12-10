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

output "key_protect_guid" {
  description = "Key Protect GUID"
  value       = module.key_protect_all_inclusive.kms_guid
}

output "key_protect_account_id" {
  description = "The account ID of the Key Protect instance."
  value       = module.key_protect_all_inclusive.kms_account_id
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

output "kms_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = module.key_protect_all_inclusive.kms_private_endpoint
}

output "kms_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = module.key_protect_all_inclusive.kms_public_endpoint
}
