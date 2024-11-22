##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################

# A network zone with Service reference to schematics
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.29.0"
  name             = "${var.prefix}-network-zone"
  zone_description = "CBR Network zone for schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef"
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect_all_inclusive" {
  source                      = "../.."
  resource_group_id           = module.resource_group.resource_group_id
  key_protect_instance_name   = "${var.prefix}-slz-kms"
  region                      = var.region
  resource_tags               = var.resource_tags
  access_tags                 = var.access_tags
  key_protect_allowed_network = "private-only"
  key_ring_endpoint_type      = "private"
  key_endpoint_type           = "private"
  keys = [
    # Create one new Key Ring with multiple new Keys in it
    {
      key_ring_name = "${var.prefix}-slz-ring"
      keys = [
        {
          key_name     = "${var.prefix}-slz-key"
          force_delete = true # Setting it to true for testing purpose
        },
        {
          key_name     = "${var.prefix}-atracker-key"
          force_delete = true
        },
        {
          key_name     = "${var.prefix}-vsi-volume-key"
          force_delete = true
        }
      ]
    }
  ]
  # CBR rule only allowing the Key Protect instance to be accessbile from Schematics
  cbr_rules = [{
    description      = "key-protect access only from schematics"
    enforcement_mode = "enabled"
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    rule_contexts = [{
      attributes = [
        {
          name  = "networkZoneId"
          value = module.cbr_zone.zone_id
        }
      ]
    }]
  }]
}
