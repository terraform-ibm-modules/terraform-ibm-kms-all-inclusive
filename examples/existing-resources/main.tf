##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Key Protect instance outside of terraform-ibm-key-protect-all-inclusive module
##############################################################################
module "existing_key_protect" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.2.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  tags              = var.resource_tags
  key_protect_name  = "${var.prefix}-kp"
}

##############################################################################
# Create Key Ring outside of terraform-ibm-key-protect-all-inclusive module
##############################################################################

locals {
  key_ring_id = "${var.prefix}-existing-key-ring"
}

module "existing_key_ring" {
  source      = "terraform-ibm-modules/key-protect-key-ring/ibm"
  version     = "2.0.1"
  instance_id = module.existing_key_protect.key_protect_guid
  key_ring_id = local.key_ring_id
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  depends_on                         = [module.existing_key_ring]
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  region                             = var.region
  resource_tags                      = var.resource_tags
  access_tags                        = var.access_tags
  create_key_protect_instance        = false
  existing_key_protect_instance_guid = module.existing_key_protect.key_protect_guid
  existing_key_map = {
    # create a new key in an existing key ring
    (local.key_ring_id) = [
      "test-key"
    ]
  }
  key_map = {
    # "ocp" key ring will be created with a key called "ocp-cluster-1-key"
    "ocp" = [
      "ocp-cluster-1-key"
    ]
  }
}
