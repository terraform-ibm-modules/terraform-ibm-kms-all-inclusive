##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group in which you want to provision your instance of Key Protext. Not required if 'create_key_protect_instance' is set to false."
  default     = null
}

variable "region" {
  type        = string
  description = "The IBM Cloud region in which your resources will be provisioned."
}

variable "create_key_protect_instance" {
  type        = bool
  description = "A boolean that determines whether a Key Protect instance is created. By default, this is set to true."
  default     = true

  validation {
    condition     = !var.create_key_protect_instance || var.resource_group_id != null
    error_message = "A value must be passed for 'resource_group_id' when 'create_key_protect_instance' is true"
  }
}

variable "key_protect_instance_name" {
  type        = string
  description = "The name to give the Key Protect instance that will be provisioned by this module. Not required if 'create_key_protect_instance' is set to false."
  default     = "key-protect"
}

variable "key_protect_plan" {
  type        = string
  description = "The pricing plan for the Key Protect instance. Supported values are 'tiered-pricing' and 'cross-region-resiliency'. Not required if 'create_key_protect_instance' is set to false."
  default     = "tiered-pricing"
  # validation performed in terraform-ibm-key-protect module
}

variable "rotation_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a rotation policy for the instance. Not required if 'create_key_protect_instance' is set to false."
  default     = true
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive. Not required if 'create_key_protect_instance' is set to false."
  default     = 1
}

variable "dual_auth_delete_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a dual authorization policy on the instance. Once the dual authorization policy is set it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed by using Terraform. Not required if 'create_key_protect_instance' is set to false."
  default     = false
}

variable "enable_metrics" {
  type        = bool
  description = "Set to true to enable metrics on the instance. Not required if 'create_key_protect_instance' is set to false. To view metrics, you will need a Monitoring instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}

variable "key_create_import_access_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a key create import access policy on the instance. Not required if 'create_key_protect_instance' is set to false."
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
  description = "Key create import access policy settings to configure if 'enable_key_create_import_access_policy' is true. Not required if 'create_key_protect_instance' is set to false. For more information see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess"
  default     = {}
}

variable "key_protect_allowed_network" {
  type        = string
  description = "The type of the network connection that is allowed for the instance. Supported values are 'private-only', or 'public-and-private'. Not required if 'create_key_protect_instance' is set to false."
  default     = "public-and-private"
  validation {
    condition     = can(regex("private-only|public-and-private", var.key_protect_allowed_network))
    error_message = "The 'key_protect_allowed_network' value must be set to either 'private-only' or 'public-and-private'."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of an existing instance. Required if 'create_key_protect_instance' is false."
  default     = null

  validation {
    condition     = !(var.create_key_protect_instance && var.existing_kms_instance_crn != null)
    error_message = "If you provide a value for 'existing_kms_instance_crn', then 'create_key_protect_instance' cannot be set to 'true'."
  }

  validation {
    condition     = var.create_key_protect_instance || var.existing_kms_instance_crn != null
    error_message = "If 'create_key_protect_instance' is false, then a value must be provided for 'existing_kms_instance_crn'."
  }
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
  description = "A list of objects that contains the key ring name, a flag indicating if this key ring already exists, and a flag to enable force deletion of the key ring. In addition, this object contains a list of keys with all of the information on the keys that will be created in that key ring."
  sensitive   = true
  default     = []
}

variable "key_ring_endpoint_type" {
  type        = string
  description = "The type of endpoint that you want to use to create key rings in your instance. Supported values are 'public' or 'private'."
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.key_ring_endpoint_type))
    error_message = "The endpoint_type value must be 'public' or 'private'."
  }
}

variable "key_endpoint_type" {
  type        = string
  description = "The type of endpoint that you want to use to create keys in your instance. Supported values are 'public' or 'private'."
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.key_endpoint_type))
    error_message = "The endpoint_type value must be 'public' or 'private'."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "An optional list of tags to be added to the instance. Not required if 'create_key_protect_instance' is set to false."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags that you want to apply to the instance. Not required if 'create_key_protect_instance' is set to false."
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
    error_message = "When passing an HPCS instance as value for `existing_kms_instance_crn` you cannot provide `cbr_rules`. Context-based restrictions is not supported for HPCS instances. For more information, see https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#cbr-adopters for the services that supports CBR."
  }
}
