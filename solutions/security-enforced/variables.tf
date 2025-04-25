########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision key management resources to. If a prefix input variable is specified, it's added to the value in the `<prefix>-value` format."
  default     = "Default"
  nullable    = false
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "The region in which to provision key management resources. If using an existing Key Protect or Hyper Protect Crypto Services instance, set this to the region where it was provisioned."
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources that this solution creates. To not use any prefix value, you can set this value to `null` or an empty string."
  default     = null
}

########################################################################################################################
# Key Protect instance variables
########################################################################################################################

variable "key_protect_instance_name" {
  type        = string
  default     = "key-protect"
  description = "The name to give the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance. If a prefix input variable is specified, it's added to the value in the `<prefix>-value` format."
}

variable "key_protect_plan" {
  type        = string
  default     = "tiered-pricing"
  description = "The service plan of the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance."

  validation {
    condition     = contains(["tiered-pricing", "cross-region-resiliency"], var.key_protect_plan)
    error_message = "`key_protect_plan` must be one of: 'tiered-pricing', 'cross-region-resiliency'."
  }

  validation {
    condition     = var.key_protect_plan == "tiered-pricing" ? true : (var.key_protect_plan == "cross-region-resiliency" && contains(["us-south", "eu-de", "jp-tok"], var.region))
    error_message = "'cross-region-resiliency' is only available for the following regions: 'us-south', 'eu-de', 'jp-tok'."
  }
}

variable "key_protect_resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the Key Protect instance. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance."
  default     = []
}

variable "key_protect_access_tags" {
  type        = list(string)
  description = "Optional list of access tags to apply to the Key Protect instance. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance."
  default     = []
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies the key rotation time interval in months. Possible values: `1` through `12`. Applies only if an existing Key Protect or Hyper Protect Crypto Services instance is not specified."
  default     = 12
}

########################################################################################################################
# Existing KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existing Hyper Protect Crypto Services or Key Protect instance. If not supplied, a new instance will be created."
}

########################################################################################################################
# Key Ring / Key variables
########################################################################################################################

variable "keys" {
  type = list(object({
    key_ring_name     = string
    existing_key_ring = optional(bool, false)
    keys = list(object({
      key_name                 = string
      standard_key             = optional(bool, false)
      rotation_interval_month  = optional(number, 1)
      dual_auth_delete_enabled = optional(bool, false)
      force_delete             = optional(bool, true)
      kmip = optional(list(object({
        name        = string
        description = optional(string)
        certificates = optional(list(object({
          name        = optional(string)
          certificate = string
        })), [])
      })), [])
    }))
  }))
  description = "A list of key ring objects each containing one or more key objects. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/solutions/standard/DA-keys.md)."
  sensitive   = true
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "key_protect_instance_cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "(Optional, list) List of context-based restrictions rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/solutions/standard/DA-cbr_rules.md)"
  default     = []
  # NOTE: Context-based restrictions rule applies to Key Protect instances and is not supported for HPCS instances
}
