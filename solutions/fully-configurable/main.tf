########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.0"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# KMS
########################################################################################################################

locals {
  parsed_existing_kms_instance_crn = var.existing_kms_instance_crn != null ? split(":", var.existing_kms_instance_crn) : []
  existing_kms_guid                = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[7] : null
  kp_endpoint_type                 = var.key_protect_allowed_network == "private-only" ? "private" : "public"
  kms_endpoint_type                = var.existing_kms_instance_crn != null ? var.kms_endpoint_type : local.kp_endpoint_type
  prefix                           = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  kms_crn                          = var.existing_kms_instance_crn == null ? module.kms.key_protect_crn : var.existing_kms_instance_crn
}

module "kms" {
  source                            = "../.."
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = var.region
  create_key_protect_instance       = local.existing_kms_guid != null ? false : true
  existing_kms_instance_crn         = var.existing_kms_instance_crn
  key_protect_instance_name         = "${local.prefix}${var.key_protect_instance_name}"
  key_protect_plan                  = var.key_protect_plan
  rotation_enabled                  = true
  rotation_interval_month           = var.rotation_interval_month
  dual_auth_delete_enabled          = false
  enable_metrics                    = true
  key_create_import_access_enabled  = false
  key_create_import_access_settings = {} # TBC - should this be exposed to consumer? Or hard coded to best practise?
  key_protect_allowed_network       = var.key_protect_allowed_network
  key_ring_endpoint_type            = local.kms_endpoint_type
  key_endpoint_type                 = local.kms_endpoint_type
  resource_tags                     = var.key_protect_resource_tags
  access_tags                       = var.key_protect_access_tags
  keys                              = var.keys
  cbr_rules                         = var.key_protect_instance_cbr_rules
}
