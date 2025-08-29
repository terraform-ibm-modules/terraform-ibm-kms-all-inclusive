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
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "region" {
  type        = string
  description = "The region to provision all resources in if using this deployable architecture to provision them. If using an existing key, this input will be not required. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/region) about how to select different regions for different services."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-045-kms. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

########################################################################################################################
# Key Protect instance variables
########################################################################################################################

variable "key_protect_instance_name" {
  type        = string
  default     = "key-protect"
  description = "The name to give the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<instance_name>` format."
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

variable "key_protect_allowed_network" {
  type        = string
  description = "The type of the allowed network to be set for the Key Protect instance. Possible values: `private-only`, `public-and-private`. Applies only if an existing Key Protect or Hyper Protect Crypto Services instance is not specified."
  default     = "private-only"
  validation {
    condition     = can(regex("private-only|public-and-private", var.key_protect_allowed_network))
    error_message = "The key_protect_allowed_network value must be 'private-only' or 'public-and-private'."
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
  description = "Specifies the key rotation time interval in months. Applicable only if a Key Protect instance is created by this solution."
  default     = 3
}

########################################################################################################################
# Existing KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existing Key Protect or Hyper Protect Crypto Services instance. If not supplied, a new instance will be created."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for creating keys and key rings in the existing Hyper Protect Crypto Services or Key Protect instance. Possible values: `public`, `private`. Applies only if an existing Hyper Protect Crypto Services or Key Protect instance is specified."
  default     = "private"
  # validation is performed in root module
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
  description = "A list of Key Ring objects each containing one or more Key objects. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/blob/main/solutions/fully-configurable/DA-keys.md)."
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
  description = "List of Context-Based Restriction rules to create for Key Protect instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/blob/main/solutions/fully-configurable/DA-cbr_rules.md)."
  default     = []
  # NOTE: Context-based restrictions rule applies to Key Protect instances and is not supported for HPCS instances
}
