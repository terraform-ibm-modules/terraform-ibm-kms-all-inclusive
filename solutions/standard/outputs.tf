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
  description = "Key Protect instance GUID or the KMS instance GUID if an existing KMS GUID was set"
  value       = module.kms.kms_guid
}

output "key_protect_id" {
  description = "Key Protect instance ID when an instance is created, otherwise null"
  value       = module.kms.key_protect_id
}

output "key_protect_crn" {
  description = "Key Protect instance CRN when an instance is created, otherwise null"
  value       = module.kms.key_protect_crn
}

output "key_protect_name" {
  description = "Key Protect instance name when an instance is created, otherwise null"
  value       = module.kms.key_protect_name
}

output "key_protect_instance_policies" {
  description = "Key Protect instance Polices of the Key Protect instance when an instance is created, otherwise null"
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
  description = "Key Protect instance private endpoint URL when an instance is created, otherwise null"
  value       = module.kms.kp_private_endpoint
}

output "kp_public_endpoint" {
  description = "Key Protect instance public endpoint URL when an instance is created, otherwise null"
  value       = module.kms.kp_public_endpoint
}
