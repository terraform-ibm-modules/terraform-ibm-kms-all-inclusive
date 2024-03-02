##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.1.5"
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
  keys = [
    {
      key_ring_name     = "default"
      existing_key_ring = true
      keys = [
        {
          key_name = "default-key"
        }
      ]
    },
    {
      key_ring_name = "ocp"
      keys = [
        {
          key_name = "ocp-cluster-1-key"
        }
      ]
    },
    {
      key_ring_name = "cos"
      keys = [
        {
          key_name = "cos-bucket-1-key"
        },
        {
          key_name = "cos-bucket-2-key"
        }
      ]
    }
  ]
}
