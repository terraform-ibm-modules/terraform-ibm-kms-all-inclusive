##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
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
  key_map = {
    "${var.prefix}-slz-ring" = [
      "${var.prefix}-slz-key",
      "${var.prefix}-atracker-key",
      "${var.prefix}-vsi-volume-key"
    ]
  }
}
