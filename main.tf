##############################################################################
# Key Protect Instance
##############################################################################

locals {
  # set key_protect_guid as either the ID of the passed in name of instance or the one created here
  key_protect_guid = var.create_key_protect_instance ? module.key_protect[0].key_protect_guid : data.ibm_resource_instance.existing_key_protect[0].guid
}

module "key_protect" {
  count             = var.create_key_protect_instance ? 1 : 0
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect.git?ref=v1.0.0"
  key_protect_name  = var.key_protect_instance_name != null ? var.key_protect_instance_name : "${var.prefix}-kp"
  region            = var.region
  service_endpoints = var.key_protect_endpoint_type
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags
  metrics_enabled   = var.enable_metrics
}

data "ibm_resource_instance" "existing_key_protect" {
  count             = var.create_key_protect_instance ? 0 : 1
  name              = var.key_protect_instance_name
  location          = var.region
  resource_group_id = var.resource_group_id
  service           = "kms"
}

##############################################################################
# Key Protect Key Rings
##############################################################################

module "key_protect_key_rings" {
  source        = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key-ring.git?ref=v1.0.0"
  for_each      = var.key_map
  instance_id   = local.key_protect_guid
  endpoint_type = var.key_ring_endpoint_type
  key_ring_id   = each.key == "default" ? "${var.prefix}-default" : each.key
}

data "ibm_kms_key_rings" "existing_key_rings" {
  count       = var.use_existing_key_rings ? 1 : 0
  instance_id = local.key_protect_guid
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
        key_ring_name = contains(data.ibm_kms_key_rings.existing_key_rings[0].key_rings[*].id, key_ring) ? key_ring : "default"
      }
    ]
  ])

  key_ring_key_map = flatten([
    for key_ring, key_list in var.key_map : [
      for key_name in key_list : {
        key_name      = key_name
        key_ring_name = key_ring == "default" ? "${var.prefix}-default" : key_ring
      }
    ]
  ])
}

module "key_protect_keys" {
  # depends_on necessary since we're not directly referencing the previously provisioned key rings in the module
  depends_on = [
    module.key_protect_key_rings,
  ]
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git?ref=v1.0.0"
  # This for_each is needed to assign a name to the maps in the array so they can be referenced/saved in the terraform graph
  for_each                = { for map_name in local.key_ring_key_map : "${map_name.key_ring_name}.${map_name.key_name}" => map_name }
  endpoint_type           = var.key_endpoint_type
  key_protect_instance_id = local.key_protect_guid
  key_name                = each.value.key_name
  key_protect_key_ring_id = each.value.key_ring_name
  force_delete            = true
}

module "existing_key_ring_keys" {
  # depends_on necessary since we're not directly referencing the previously provisioned key rings in the module
  depends_on = [
    data.ibm_kms_key_rings.existing_key_rings
  ]
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git?ref=v1.0.0"
  # This for_each is needed to assign a name to the maps in the array so they can be referenced/saved in the terraform graph
  for_each                = { for map_name in local.existing_key_ring_key_map : "existing-key-ring.${map_name.key_name}" => map_name }
  key_protect_instance_id = local.key_protect_guid
  endpoint_type           = var.key_endpoint_type
  key_name                = each.value.key_name
  key_protect_key_ring_id = each.value.key_ring_name
  force_delete            = true
}
