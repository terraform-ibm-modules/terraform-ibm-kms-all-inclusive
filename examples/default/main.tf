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
  key_protect_instance_name = "${var.prefix}-kp"
  region                    = var.region
  resource_tags             = var.resource_tags
  access_tags               = var.access_tags
  existing_key_map = {
    # "default" king ring already exists out of the box with Key Protect, so just the key will be created here
    "default" = [
      "default-key"
    ]
  }
  key_map = {
    # "ocp" key ring will be created with a key called "ocp-cluster-1-key"
    "ocp" = [
      "ocp-cluster-1-key"
    ],
    # "cos" key ring will be created with 2 keys called "cos-bucket-1-key" and "cos-bucket-2-key"
    "cos" = [
      "cos-bucket-1-key",
      "cos-bucket-2-key"
    ]
  }
}
