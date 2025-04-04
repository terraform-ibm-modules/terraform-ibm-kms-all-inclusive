########################################################################################################################
# KMS
########################################################################################################################

module "security_enforced" {
  source                         = "../fully-configurable"
  ibmcloud_api_key               = var.ibmcloud_api_key
  provider_visibility            = var.provider_visibility
  existing_resource_group_name   = var.existing_resource_group_name
  region                         = var.region
  prefix                         = var.prefix
  key_protect_instance_name      = var.key_protect_instance_name
  key_protect_plan               = var.key_protect_plan
  key_protect_allowed_network    = "private-only"
  key_protect_resource_tags      = var.key_protect_resource_tags
  key_protect_access_tags        = var.key_protect_access_tags
  rotation_interval_month        = var.rotation_interval_month
  existing_kms_instance_crn      = var.existing_kms_instance_crn
  kms_endpoint_type              = "private"
  keys                           = var.keys
  key_protect_instance_cbr_rules = var.key_protect_instance_cbr_rules
}
