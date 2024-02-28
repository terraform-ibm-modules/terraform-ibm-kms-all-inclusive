########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "kms_guid" {
  description = "KMS GUID"
  value       = module.kms.kms_guid
}

output "key_protect_name" {
  description = "Key Protect name"
  value       = module.kms.key_protect_name
}

output "key_protect_instance_policies" {
  description = "Instance Polices of the Key Protect instance"
  value       = module.kms.key_protect_instance_policies
}

output "key_rings" {
  description = "IDs of Key Rings created by the solution"
  value       = module.kms.key_rings
}

output "keys" {
  description = "Keys created by the solution"
  value       = module.kms.keys
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = module.kms.kp_private_endpoint
}

output "kp_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = module.kms.kp_public_endpoint
}
