##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
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
  version          = "1.33.8"
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
# Secrets Manager Certificate Setup
##############################################################################

module "secrets_manager" {
  count                = var.existing_secrets_manager_crn == null ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.11.9"
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "trial"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
}

module "sm_crn" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.0"
  crn     = var.existing_secrets_manager_crn == null ? module.secrets_manager[0].secrets_manager_crn : var.existing_secrets_manager_crn
}

locals {
  certificate_template_name = var.existing_cert_template_name == null ? "${var.prefix}-template" : var.existing_cert_template_name
}

module "secrets_manager_private_cert_engine" {
  count                     = var.existing_secrets_manager_crn == null && var.existing_cert_template_name == null ? 1 : 0
  source                    = "terraform-ibm-modules/secrets-manager-private-cert-engine/ibm"
  version                   = "1.11.1"
  secrets_manager_guid      = module.sm_crn.service_instance
  region                    = var.region
  root_ca_name              = "${var.prefix}-ca"
  root_ca_common_name       = "*.cloud.ibm.com"
  intermediate_ca_name      = "${var.prefix}-int-ca"
  certificate_template_name = local.certificate_template_name
  root_ca_max_ttl           = "8760h"
}

module "secrets_manager_cert" {
  # explicit depends on because the cert engine must complete creating the template before the cert is created
  # no outputs from the private cert engine to reference in this module call
  depends_on             = [module.secrets_manager_private_cert_engine]
  source                 = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version                = "1.7.5"
  secrets_manager_guid   = module.sm_crn.service_instance
  secrets_manager_region = module.sm_crn.region
  cert_name              = "${var.prefix}-kmip-cert"
  cert_common_name       = "*.cloud.ibm.com"
  cert_template          = local.certificate_template_name
}

data "ibm_sm_private_certificate" "kmip_cert" {
  instance_id = module.sm_crn.service_instance
  region      = module.sm_crn.region
  secret_id   = module.secrets_manager_cert.secret_id
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
          kmip = [
            {
              name = "${var.prefix}-kmip-adapter-1"
              certificates = [
                {
                  certificate = data.ibm_sm_private_certificate.kmip_cert.certificate
                }
              ]
            }
          ]
        },
        {
          key_name     = "${var.prefix}-atracker-key"
          force_delete = true
          kmip = [
            {
              name = "${var.prefix}-kmip-adapter-2"
            }
          ]
        },
        {
          key_name     = "${var.prefix}-vsi-volume-key"
          force_delete = true
        }
      ]
    }
  ]
  # CBR rule only allowing the Key Protect instance to be accessible from Schematics
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
