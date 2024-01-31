##############################################################################
# Key Protect Instance
##############################################################################

locals {
  # variable validation around new instance vs existing
  instance_validate_condition = var.create_key_protect_instance && var.existing_key_protect_instance_guid != null
  instance_validate_msg       = "'create_key_protect_instance' cannot be true when passing a value for 'existing_key_protect_instance_guid'"
  # tflint-ignore: terraform_unused_declarations
  instance_validate_check = regex("^${local.instance_validate_msg}$", (!local.instance_validate_condition ? local.instance_validate_msg : ""))

  # variable validation when creating new instance
  new_instance_validate_condition = var.create_key_protect_instance && var.key_protect_instance_name == null
  new_instance_validate_msg       = "A value must be provided for 'key_protect_instance_name' when 'create_key_protect_instance' is true"
  # tflint-ignore: terraform_unused_declarations
  new_instance_validate_check = regex("^${local.new_instance_validate_msg}$", (!local.new_instance_validate_condition ? local.new_instance_validate_msg : ""))

  # variable validation when not creating new instance
  existing_instance_validate_condition = !var.create_key_protect_instance && var.existing_key_protect_instance_guid == null
  existing_instance_validate_msg       = "A value must be provided for 'existing_key_protect_instance_guid' when 'create_key_protect_instance' is false"
  # tflint-ignore: terraform_unused_declarations
  existing_instance_validate_check = regex("^${local.existing_instance_validate_msg}$", (!local.existing_instance_validate_condition ? local.existing_instance_validate_msg : ""))

  # set key_protect_guid as either the ID of the passed in name of instance or the one created by this module
  key_protect_guid = var.create_key_protect_instance ? module.key_protect[0].key_protect_guid : var.existing_key_protect_instance_guid
}

module "key_protect" {
  count                             = var.create_key_protect_instance ? 1 : 0
  source                            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect.git?ref=v2.5.0"
  key_protect_name                  = var.key_protect_instance_name
  region                            = var.region
  service_endpoints                 = var.key_protect_endpoint_type
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
# Key Protect Key Rings
##############################################################################

# Create Key Rings included in var.existing_key_map
module "key_protect_key_rings" {
  source        = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key-ring.git?ref=v2.3.1"
  for_each      = var.key_map
  instance_id   = local.key_protect_guid
  endpoint_type = var.key_ring_endpoint_type
  key_ring_id   = each.key
  force_delete  = var.force_delete_key_ring
}

##############################################################################
# Key Protect Keys
##############################################################################

locals {
  # These two maps transform the variable data from
  # {key_ring_1 = [key_1, key_2], key_ring_2 = [key_3, key_4]}
  # into a more usable data structure of
  # [{key_name = key_1, key_ring_name = key_ring_1}, {key_name = key_2, key_ring_name = key_ring_1}...]

  existing_key_ring_key_map = flatten([
    for key_ring, key_list in var.existing_key_map : [
      for key_name in key_list : {
        key_name      = key_name
        key_ring_name = key_ring
      }
    ]
  ])

  key_ring_key_map = flatten([
    for key_ring, key_list in var.key_map : [
      for key_name in key_list : {
        key_name      = key_name
        key_ring_name = key_ring
      }
    ]
  ])
}

# Create Key Rings and Keys
module "key_protect_keys" {
  # depends_on necessary since we're not directly referencing the previously provisioned key rings in the module
  depends_on = [
    module.key_protect_key_rings
  ]
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git?ref=v1.2.1"
  # This for_each is needed to assign a name to the maps in the array so they can be referenced/saved in the terraform graph
  for_each        = { for map_name in local.key_ring_key_map : "${map_name.key_ring_name}.${map_name.key_name}" => map_name }
  endpoint_type   = var.key_endpoint_type
  kms_instance_id = local.key_protect_guid
  key_name        = each.value.key_name
  kms_key_ring_id = each.value.key_ring_name
  force_delete    = var.force_delete
}

# Create Keys in existing Key Rings
module "existing_key_ring_keys" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git?ref=v1.2.1"
  # This for_each is needed to assign a name to the maps in the array so they can be referenced/saved in the terraform graph
  for_each        = { for map_name in local.existing_key_ring_key_map : "existing-key-ring.${map_name.key_name}" => map_name }
  kms_instance_id = local.key_protect_guid
  endpoint_type   = var.key_endpoint_type
  key_name        = each.value.key_name
  kms_key_ring_id = each.value.key_ring_name
  force_delete    = true
}
