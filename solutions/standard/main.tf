########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

########################################################################################################################
# KMS
########################################################################################################################

module "kms" {
  source                            = "../.."
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = var.region
  create_key_protect_instance       = var.existing_kms_guid != null ? false : true
  key_protect_instance_name         = var.key_protect_instance_name
  key_protect_plan                  = "tiered-pricing"
  rotation_enabled                  = true
  rotation_interval_month           = 3
  dual_auth_delete_enabled          = false
  enable_metrics                    = true
  key_create_import_access_enabled  = false
  key_create_import_access_settings = {} # TBC - should this be exposed to consumer? Or hard coded to best practise?
  key_protect_allowed_network       = var.service_endpoints == "private" ? "private-only" : var.service_endpoints
  key_ring_endpoint_type            = var.service_endpoints == "public-and-private" ? "public" : var.service_endpoints
  key_endpoint_type                 = var.service_endpoints == "public-and-private" ? "public" : var.service_endpoints
  existing_kms_instance_guid        = var.existing_kms_guid
  resource_tags                     = var.resource_tags
  access_tags                       = var.access_tags
  keys                              = var.keys
}
