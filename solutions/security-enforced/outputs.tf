########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.security_enforced.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.security_enforced.resource_group_id
}

output "kms_guid" {
  description = "Key Protect instance GUID or the KMS instance GUID if an existing KMS GUID was set"
  value       = module.security_enforced.kms_guid
}

output "kms_account_id" {
  description = "The account ID of the KMS instance."
  value       = module.security_enforced.kms_account_id
}

output "key_protect_id" {
  description = "Key Protect instance ID when an instance is created, otherwise null"
  value       = module.security_enforced.key_protect_id
}

output "kms_instance_crn" {
  value       = module.security_enforced.kms_instance_crn
  description = "The CRN of the Hyper Protect Crypto Service instance or Key Protect instance"
}

output "key_protect_name" {
  description = "Key Protect instance name when an instance is created, otherwise null"
  value       = module.security_enforced.key_protect_name
}

output "key_protect_instance_policies" {
  description = "Key Protect instance Polices of the Key Protect instance when an instance is created, otherwise null"
  value       = module.security_enforced.key_protect_instance_policies
}

output "key_rings" {
  description = "IDs of Key Rings created by the solution"
  value       = module.security_enforced.key_rings
}

output "keys" {
  description = "Keys created by the solution"
  value       = module.security_enforced.keys
}

output "kms_private_endpoint" {
  description = "Key Management Service instance private endpoint URL."
  value       = module.security_enforced.kms_private_endpoint
}

output "kms_public_endpoint" {
  description = "Key Management Service instance public endpoint URL."
  value       = module.security_enforced.kms_public_endpoint
}

##############################################################################
# KEY PROTECT Next Steps URLs outputs
##############################################################################

output "next_steps_text" {
  value       = module.security_enforced.next_steps_text
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = module.security_enforced.next_step_primary_label
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.security_enforced.next_step_primary_url 
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = module.security_enforced.next_step_secondary_label
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       =  module.security_enforced.next_step_secondary_url
  description = "Secondary URL"
}

##############################################################################
