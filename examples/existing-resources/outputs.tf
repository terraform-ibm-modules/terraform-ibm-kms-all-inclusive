##############################################################################
# Outputs
##############################################################################

output "key_rings" {
  description = "IDs of Key Rings created by the module"
  value       = module.key_protect_all_inclusive.key_rings
}

output "keys" {
  description = "Keys created by the module"
  value       = module.key_protect_all_inclusive.keys
}
