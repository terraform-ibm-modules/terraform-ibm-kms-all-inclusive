##############################################################################
# Variable validation
##############################################################################

locals {

  parsed_existing_kms_instance_crn = var.existing_kms_instance_crn != null ? split(":", var.existing_kms_instance_crn) : []
  existing_kms_instance_guid       = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[7] : null
  existing_kms_account_id          = length(local.parsed_existing_kms_instance_crn) > 0 ? split("/", local.parsed_existing_kms_instance_crn[6])[1] : null

  # set key_protect_guid as either the ID of the passed in name of instance or the one created by this module
  kms_guid = var.create_key_protect_instance ? module.key_protect[0].key_protect_guid : local.existing_kms_instance_guid
  # set kms_account_id as either the ID of the passed in instance or the one created by this module
  kms_account_id = var.create_key_protect_instance ? module.key_protect[0].key_protect_account_id : local.existing_kms_account_id
}

##############################################################################
# Key Protect Instance
##############################################################################

data "ibm_resource_instance" "existing_kms_instance" {
  count      = var.create_key_protect_instance ? 0 : 1
  identifier = local.existing_kms_instance_guid
}

locals {
  kms_public_endpoint  = var.create_key_protect_instance ? module.key_protect[0].kp_public_endpoint : data.ibm_resource_instance.existing_kms_instance[0].extensions["endpoints.public"]
  kms_private_endpoint = var.create_key_protect_instance ? module.key_protect[0].kp_private_endpoint : data.ibm_resource_instance.existing_kms_instance[0].extensions["endpoints.private"]
}

module "key_protect" {
  count                             = var.create_key_protect_instance ? 1 : 0
  source                            = "terraform-ibm-modules/key-protect/ibm"
  version                           = "2.10.42"
  key_protect_name                  = var.key_protect_instance_name
  region                            = var.region
  allowed_network                   = var.key_protect_allowed_network
  resource_group_id                 = var.resource_group_id
  plan                              = var.key_protect_plan
  tags                              = var.resource_tags
  access_tags                       = var.access_tags
  rotation_enabled                  = var.rotation_enabled
  rotation_interval_month           = var.rotation_interval_month
  metrics_enabled                   = var.enable_metrics
  dual_auth_delete_enabled          = var.dual_auth_delete_enabled
  key_create_import_access_enabled  = var.key_create_import_access_enabled
  key_create_import_access_settings = var.key_create_import_access_settings
  cbr_rules                         = var.cbr_rules
}

##############################################################################
# KMS Key Rings
##############################################################################

locals {
  key_rings = flatten([
    for key_ring in var.keys :
    key_ring.existing_key_ring ? [] : [{
      key_ring_name = key_ring.key_ring_name
    }]
  ])
}

module "kms_key_rings" {
  source        = "terraform-ibm-modules/kms-key-ring/ibm"
  version       = "v2.6.21"
  for_each      = { for obj in nonsensitive(local.key_rings) : obj.key_ring_name => obj }
  instance_id   = local.kms_guid
  endpoint_type = var.key_ring_endpoint_type
  key_ring_id   = each.value.key_ring_name
}

moved {
  from = module.key_protect_key_rings
  to   = module.kms_key_rings
}

##############################################################################
# KMS Keys
##############################################################################

locals {
  key_ring_key_list = flatten([
    for key_ring in var.keys : key_ring.existing_key_ring ? [] : [
      for key_obj in key_ring.keys : merge({
        key_ring_name = key_ring.key_ring_name
      }, key_obj)
    ]
  ])

  existing_key_ring_key_list = flatten([
    for key_ring in var.keys : !key_ring.existing_key_ring ? [] : [
      for key_obj in key_ring.keys : merge({
        key_ring_name = key_ring.key_ring_name
      }, key_obj)
    ]
  ])
}

# Create Key Rings and Keys
module "kms_keys" {
  source                   = "terraform-ibm-modules/kms-key/ibm"
  version                  = "v1.4.18"
  for_each                 = { for obj in nonsensitive(local.key_ring_key_list) : "${obj.key_ring_name}.${obj.key_name}" => obj }
  endpoint_type            = var.key_endpoint_type
  kms_instance_id          = local.kms_guid
  key_name                 = each.value.key_name
  kms_key_ring_id          = module.kms_key_rings[each.value.key_ring_name].key_ring_id
  force_delete             = each.value.force_delete
  standard_key             = each.value.standard_key
  rotation_interval_month  = each.value.rotation_interval_month
  dual_auth_delete_enabled = each.value.dual_auth_delete_enabled
  kmip                     = each.value.kmip
}

moved {
  from = module.key_protect_keys
  to   = module.kms_keys
}

# Create Keys in existing Key Rings
module "existing_key_ring_keys" {
  source                   = "terraform-ibm-modules/kms-key/ibm"
  version                  = "v1.4.18"
  for_each                 = { for obj in nonsensitive(local.existing_key_ring_key_list) : "existing-key-ring.${obj.key_name}" => obj }
  kms_instance_id          = local.kms_guid
  endpoint_type            = var.key_endpoint_type
  key_name                 = each.value.key_name
  kms_key_ring_id          = each.value.key_ring_name
  force_delete             = each.value.force_delete
  standard_key             = each.value.standard_key
  rotation_interval_month  = each.value.rotation_interval_month
  dual_auth_delete_enabled = each.value.dual_auth_delete_enabled
  kmip                     = each.value.kmip
}

##############################################################################
# Context Based Restrictions
##############################################################################

moved {
  from = module.cbr_rule
  to   = module.key_protect[0].module.cbr_rule
}
