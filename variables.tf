##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the Resource Group to provision the Key Protect instance in. Not required if 'create_key_protect_instance' is false."
  default     = null
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where all resources will be provisioned."
}

variable "create_key_protect_instance" {
  type        = bool
  description = "A flag to control whether a Key Protect instance is created, defaults to true."
  default     = true

  validation {
    condition     = var.create_key_protect_instance ? var.resource_group_id != null : true
    error_message = "Must provide a value for `resource_group_id` if `create_key_protect_instance` is true."
  }

  validation {
    condition     = (var.create_key_protect_instance && var.existing_kms_instance_crn == null) || (!var.create_key_protect_instance && var.existing_kms_instance_crn != null)
    error_message = "`existing_kms_instance_crn` must be null if `create_key_protect_instance` is true."
  }

}

variable "key_protect_instance_name" {
  type        = string
  description = "The name to give the Key Protect instance that will be provisioned by this module. Only used if 'create_key_protect_instance' is true."
  default     = "key-protect"
}

variable "key_protect_plan" {
  type        = string
  description = "Plan for the Key Protect instance. Supported values are 'tiered-pricing' and 'cross-region-resiliency'. Only used if 'create_key_protect_instance' is true."
  default     = "tiered-pricing"
  # validation performed in terraform-ibm-key-protect module
}

variable "rotation_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a rotation policy on the Key Protect instance. Only used if 'create_key_protect_instance' is true."
  default     = true
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive. Only used if 'create_key_protect_instance' is true."
  default     = 1
}

variable "dual_auth_delete_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform. Only used if 'create_key_protect_instance' is true."
  default     = false
}

variable "enable_metrics" {
  type        = bool
  description = "Set to true to enable metrics on the Key Protect instance. Only used if 'create_key_protect_instance' is true. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}

variable "key_create_import_access_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a key create import access policy on the instance. Only used if 'create_key_protect_instance' is true."
  default     = true
}

variable "key_create_import_access_settings" {
  type = object({
    create_root_key     = optional(bool, true)
    create_standard_key = optional(bool, true)
    import_root_key     = optional(bool, true)
    import_standard_key = optional(bool, true)
    enforce_token       = optional(bool, false)
  })
  description = "Key create import access policy settings to configure if 'enable_key_create_import_access_policy' is true. Only used if 'create_key_protect_instance' is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess"
  default     = {}
}

variable "key_protect_allowed_network" {
  type        = string
  description = "The type of the allowed network to be set for the Key Protect instance. Possible values are 'private-only', or 'public-and-private'. Only used if 'create_key_protect_instance' is true."
  default     = "public-and-private"
  validation {
    condition     = can(regex("private-only|public-and-private", var.key_protect_allowed_network))
    error_message = "The key_protect_allowed_network value must be 'private-only' or 'public-and-private'."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of an existing Key Protect or Hyper Protect Crypto Services instance. Required if 'create_key_protect_instance' is false."
  default     = null
}

variable "keys" {
  type = list(object({
    key_ring_name     = string
    existing_key_ring = optional(bool, false)
    keys = list(object({
      key_name                 = string
      standard_key             = optional(bool, false)
      rotation_interval_month  = optional(number, 1)
      dual_auth_delete_enabled = optional(bool, false)
      force_delete             = optional(bool, false)
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
  description = "A list of objects which contain the key ring name, a flag indicating if this key ring already exists, and a flag to enable force deletion of the key ring. In addition, this object contains a list of keys with all of the information on the keys to be created in that key ring."
  sensitive   = true
  default     = []
}

variable "key_ring_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for creating key rings. Accepts 'public' or 'private'"
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.key_ring_endpoint_type))
    error_message = "The endpoint_type value must be 'public' or 'private'."
  }
}

variable "key_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for creating keys. Accepts 'public' or 'private'"
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.key_endpoint_type))
    error_message = "The endpoint_type value must be 'public' or 'private'."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the Key Protect instance. Only used if 'create_key_protect_instance' is true."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Key Protect instance created by the module. Only used if 'create_key_protect_instance' is true."
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
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
  description = "(Optional, list) List of context-based restrictions rules to create"
  default     = []
  # Validation happens in the rule module
  # NOTE: Context-based restrictions rule applies to Key Protect instances and is not supported for HPCS instances

  validation {
    # condition     = (length(regexall(".*hs-crypto.*", var.existing_kms_instance_crn)) > 0 && length(var.cbr_rules) == 0) || (length(regexall(".*kms.*", var.existing_kms_instance_crn)) > 0) || (var.existing_kms_instance_crn == null)
    condition     = var.existing_kms_instance_crn == null ? true : length(regexall(".*hscrypto.*", var.existing_kms_instance_crn)) > 0 ? length(var.cbr_rules) == 0 : true
    error_message = "When passing an HPCS instance as value for `existing_kms_instance_crn` you cannot provid `cbr_rules`. Context-based restrictions is not supported for HPCS instances. For more information, see https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#cbr-adopters for the services that supports CBR."
  }
}
