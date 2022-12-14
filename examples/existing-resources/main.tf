##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# "Existing" Key Protect instance
##############################################################################
module "existing_key_protect" {
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect.git?ref=v1.1.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  tags              = var.resource_tags
  key_protect_name  = "${var.prefix}-kp"
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  region                             = var.region
  prefix                             = var.prefix
  resource_tags                      = var.resource_tags
  create_key_protect_instance        = false
  existing_key_protect_instance_guid = module.existing_key_protect.key_protect_guid
  use_existing_key_rings             = true
  # Following topology groups all root keys related to a given service type (eg: ocp, cos) in the same key ring.
  # This facilitates access assignment, which meeting least privilege controls
  key_map          = {}
  existing_key_map = { "default" = ["default-key"] }
}
