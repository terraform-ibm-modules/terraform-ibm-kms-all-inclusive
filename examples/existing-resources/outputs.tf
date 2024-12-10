##############################################################################
# Outputs
##############################################################################

output "kms_account_id" {
  description = "The account ID of the KMS instance."
  value       = module.key_protect_all_inclusive.kms_account_id
}

output "key_rings" {
  description = "IDs of Key Rings created by the module"
  value       = module.key_protect_all_inclusive.key_rings
}

output "keys" {
  description = "Keys created by the module"
  value       = module.key_protect_all_inclusive.keys
}
