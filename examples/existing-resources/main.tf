##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                      = "../.."
  region                      = var.region
  create_key_protect_instance = false
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  keys = [
    {
      key_ring_name         = "default"
      existing_key_ring     = true
      force_delete_key_ring = true # Setting it to true for testing purpose
      keys = [
        {
          key_name     = "test-key"
          force_delete = true # Setting it to true for testing purpose
        }
      ]
    }
  ]
}
