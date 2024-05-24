##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                    = "../.."
  resource_group_id         = module.resource_group.resource_group_id
  key_protect_instance_name = "${var.prefix}-slz-kms"
  region                    = var.region
  resource_tags             = var.resource_tags
  access_tags               = var.access_tags
  keys = [
    # Create one new Key Ring with multiple new Keys in it
    {
      key_ring_name         = "${var.prefix}-slz-ring"
      force_delete_key_ring = true # Setting it to true for testing purpose
      keys = [
        {
          key_name     = "${var.prefix}-slz-key"
          force_delete = true # Setting it to true for testing purpose
        },
        {
          key_name     = "${var.prefix}-atracker-key"
          force_delete = true
        },
        {
          key_name     = "${var.prefix}-vsi-volume-key"
          force_delete = true
        }
      ]
    }
  ]
}
