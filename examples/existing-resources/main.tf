##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                      = "../.."
  region                      = var.region
  create_key_protect_instance = false
  existing_kms_instance_guid  = var.existing_kms_instance_guid
  keys = [
    {
      key_ring_name     = "default"
      existing_key_ring = true
      keys = [
        {
          key_name = "test-key"
        }
      ]
    }
  ]
}
