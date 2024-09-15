##############################################################################
# Variable validation
##############################################################################

locals {
  # variable validation around resource_group_id
  rg_validate_condition = var.create_key_protect_instance && var.resource_group_id == null
  rg_validate_msg       = "A value must be passed for 'resource_group_id' when 'create_key_protect_instance' is true"
  # tflint-ignore: terraform_unused_declarations
  rg_validate_check = regex("^${local.rg_validate_msg}$", (!local.rg_validate_condition ? local.rg_validate_msg : ""))

  parsed_existing_kms_instance_crn = var.existing_kms_instance_crn != null ? split(":", var.existing_kms_instance_crn) : []
  existing_kms_instance_guid       = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[7] : null

  # variable validation around new instance vs existing
  instance_validate_condition = var.create_key_protect_instance && local.existing_kms_instance_guid != null
  instance_validate_msg       = "'create_key_protect_instance' cannot be true when passing a value for 'existing_key_protect_instance_guid'"
  # tflint-ignore: terraform_unused_declarations
  instance_validate_check = regex("^${local.instance_validate_msg}$", (!local.instance_validate_condition ? local.instance_validate_msg : ""))

  # variable validation when not creating new instance
  existing_instance_validate_condition = !var.create_key_protect_instance && local.existing_kms_instance_guid == null
  existing_instance_validate_msg       = "A value must be provided for 'existing_key_protect_instance_guid' when 'create_key_protect_instance' is false"
  # tflint-ignore: terraform_unused_declarations
  existing_instance_validate_check = regex("^${local.existing_instance_validate_msg}$", (!local.existing_instance_validate_condition ? local.existing_instance_validate_msg : ""))

  # set key_protect_guid as either the ID of the passed in name of instance or the one created by this module
  kms_guid = var.create_key_protect_instance ? module.key_protect[0].key_protect_guid : local.existing_kms_instance_guid

  # set key_protect_crn as either the crn of the passed in name of instance or the one created by this module
  kms_crn = var.create_key_protect_instance ? module.key_protect[0].key_protect_crn : var.existing_kms_instance_crn
  # tflint-ignore: terraform_unused_declarations
  cbr_validation = length(regexall(".*hs-crypto.*", local.kms_crn)) > 0 && length(var.cbr_rules) > 0 ? tobool("When passing an HPCS instance as value for `existing_kms_instance_crn` you cannot provide `cbr_rules`. Context-based restrictions is not supported for HPCS instances. For more information, see https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#cbr-adopters for the services that supports CBR") : true
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
  version                           = "2.8.5"
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
}

##############################################################################
# KMS Key Rings
##############################################################################

locals {
  key_rings = flatten([
    for key_ring in var.keys :
    key_ring.existing_key_ring ? [] : [{
      key_ring_name = key_ring.key_ring_name
      force_delete  = key_ring.force_delete_key_ring
    }]
  ])
}

module "kms_key_rings" {
  source        = "terraform-ibm-modules/kms-key-ring/ibm"
  version       = "v2.4.1"
  for_each      = { for obj in local.key_rings : obj.key_ring_name => obj }
  instance_id   = local.kms_guid
  endpoint_type = var.key_ring_endpoint_type
  key_ring_id   = each.value.key_ring_name
  force_delete  = each.value.force_delete
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
  version                  = "v1.2.4"
  for_each                 = { for obj in local.key_ring_key_list : "${obj.key_ring_name}.${obj.key_name}" => obj }
  endpoint_type            = var.key_endpoint_type
  kms_instance_id          = local.kms_guid
  key_name                 = each.value.key_name
  kms_key_ring_id          = module.kms_key_rings[each.value.key_ring_name].key_ring_id
  force_delete             = each.value.force_delete
  standard_key             = each.value.standard_key
  rotation_interval_month  = each.value.rotation_interval_month
  dual_auth_delete_enabled = each.value.dual_auth_delete_enabled
}

moved {
  from = module.key_protect_keys
  to   = module.kms_keys
}

# Create Keys in existing Key Rings
module "existing_key_ring_keys" {
  source                   = "terraform-ibm-modules/kms-key/ibm"
  version                  = "v1.2.4"
  for_each                 = { for obj in local.existing_key_ring_key_list : "existing-key-ring.${obj.key_name}" => obj }
  kms_instance_id          = local.kms_guid
  endpoint_type            = var.key_endpoint_type
  key_name                 = each.value.key_name
  kms_key_ring_id          = each.value.key_ring_name
  force_delete             = each.value.force_delete
  standard_key             = each.value.standard_key
  rotation_interval_month  = each.value.rotation_interval_month
  dual_auth_delete_enabled = each.value.dual_auth_delete_enabled
}

##############################################################################
# Context Based Restrictions
##############################################################################

locals {
  default_operations = [{
    api_types = [
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      },
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::platform-api-type:"
      }
    ]
  }]
}

module "cbr_rule" {
  count            = length(var.cbr_rules)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.27.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name  = "accountId"
        value = var.cbr_rules[count.index].account_id
      },
      {
        name     = "serviceInstance"
        value    = local.kms_guid
        operator = "stringEquals"
      },
      {
        name  = "serviceName"
        value = "kms"
      }
    ]
  }]
  operations = var.cbr_rules[count.index].operations == null ? local.default_operations : var.cbr_rules[count.index].operations
}
