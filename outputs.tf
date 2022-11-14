##############################################################################
# Outputs
##############################################################################

output "key_protect_guid" {
  description = "Key Protect GUID"
  value       = local.key_protect_guid
}

output "key_protect_name" {
  description = "Name of the Key Protect instance"
  value       = local.key_protect_name
}

##############################################################################

output "key_rings" {
  description = "IDs of Key Rings created by the module"
  value       = module.key_protect_key_rings
}

##############################################################################

output "keys" {
  description = "IDs of Keys created by the module"
  value       = module.key_protect_keys
}

output "existing_key_ring_keys" {
  description = "IDs of Keys created by the module in existing Key Rings"
  value       = module.existing_key_ring_keys
}
