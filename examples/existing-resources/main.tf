##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                      = "../.."
  resource_group_id           = module.resource_group.resource_group_id
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
