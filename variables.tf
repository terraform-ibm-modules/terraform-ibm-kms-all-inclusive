##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group where the Key Protect instance is created. Not required if 'create_key_protect_instance' is set to `false`."
  default     = null
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where all resources are provisioned."
}

variable "create_key_protect_instance" {
  type        = bool
  description = "A flag to control whether a Key Protect instance is created. The default is `true`."
  default     = true

  validation {
    condition     = !var.create_key_protect_instance || var.resource_group_id != null
    error_message = "A value must be passed for 'resource_group_id' when 'create_key_protect_instance' is set to `true`."
  }
}

variable "key_protect_instance_name" {
  type        = string
  description = "The name to give the Key Protect instance that that is created by this module. Only used if 'create_key_protect_instance' is set to `true`."
  default     = "key-protect"
}

variable "key_protect_plan" {
  type        = string
  description = "Plan for the Key Protect instance. Supported values are 'tiered-pricing' and 'cross-region-resiliency'. Only used if 'create_key_protect_instance' is set to `true`."
  default     = "tiered-pricing"
  # validation performed in terraform-ibm-key-protect module
}

variable "rotation_enabled" {
  type        = bool
  description = "If set to `true`, a rotation policy is enabled on the Key Protect instance. Only used if 'create_key_protect_instance' is set to `true`."
  default     = true
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies how often keys are rotated in months. Value must be between `1` and `12` inclusive. Only used if 'create_key_protect_instance' is set to `true`."
  default     = 1
}

variable "dual_auth_delete_enabled" {
  type        = bool
  description = "If set to `true`, a dual authorization policy is enabled on the Key Protect instance. After the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed by using Terraform. Only used if 'create_key_protect_instance' is set to `true`."
  default     = false
}

variable "enable_metrics" {
  type        = bool
  description = "Set to `true` to enable metrics on the Key Protect instance. Only used if 'create_key_protect_instance' is set to `true`. In order to view metrics, you need an IBM Cloud Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. After you provision a Monitoring instance, enable platform metrics to monitor your Key Protect instance."
  default     = true
}

variable "key_create_import_access_enabled" {
  type        = bool
  description = "If set to `true`, a key create and import access policy is enabled on the instance of Key Protect. Only used if 'create_key_protect_instance' is set to `true`."
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
  description = "Key create and import access policy settings to configure if 'enable_key_create_import_access_policy' is set to `true`. Only used if 'create_key_protect_instance' is set to `true`. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess"
  default     = {}
}

variable "key_protect_allowed_network" {
  type        = string
  description = "Allowed network types for the Key Protect instance. Possible values are 'private-only', or 'public-and-private'. Only used if 'create_key_protect_instance' is set to `true`."
  default     = "public-and-private"
  validation {
    condition     = can(regex("private-only|public-and-private", var.key_protect_allowed_network))
    error_message = "The `key_protect_allowed_network` value must be 'private-only' or 'public-and-private'."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of an existing Key Protect or Hyper Protect Crypto Services instance. Required if 'create_key_protect_instance' is set to `false`."
  default     = null

  validation {
    condition     = !(var.create_key_protect_instance && var.existing_kms_instance_crn != null)
    error_message = "'create_key_protect_instance' cannot be set to `true` when passing a value for 'existing_kms_instance_crn'."
  }

  validation {
    condition     = var.create_key_protect_instance || var.existing_kms_instance_crn != null
    error_message = "A value must be provided for 'existing_kms_instance_crn' when 'create_key_protect_instance' is set to `false`."
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
  description = "A list of objects that contain the key ring name, a flag indicating if this key ring already exists, and a flag to enable force deletion of the key ring. This object also contains a list of keys to be created in that key ring."
  sensitive   = true
  default     = []
}

variable "key_ring_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for creating key rings. Possible values are 'public' or 'private'."
  default     = "public"
  validation {
    condition     = can(regex("^(public|private)$", var.key_ring_endpoint_type))
    error_message = "The value isn't valid. Possible values are 'public' or 'private'."
  }
}

variable "key_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for creating keys. Possible values are 'public' or 'private'"
  default     = "public"
  validation {
    condition     = can(regex("^(public|private)$", var.key_endpoint_type))
    error_message = "The value isn't valid. Possible values are 'public' or 'private'."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to add to the Key Protect instance. Only used if 'create_key_protect_instance' is set to `true`."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Key Protect instance. Only used if 'create_key_protect_instance' is set to `true`."
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
  description = "The context-based restrictions rule to create. Only one rule is allowed."
  default     = []
  # Validation happens in the rule module
  # NOTE: Context-based restriction rules applies to Key Protect instances only and is not supported by Hyper Protect Crypto Services (HPCS) instances

  validation {
    # condition     = (length(regexall(".*hs-crypto.*", var.existing_kms_instance_crn)) > 0 && length(var.cbr_rules) == 0) || (length(regexall(".*kms.*", var.existing_kms_instance_crn)) > 0) || (var.existing_kms_instance_crn == null)
    condition     = var.existing_kms_instance_crn == null ? true : length(regexall(".*hscrypto.*", var.existing_kms_instance_crn)) > 0 ? length(var.cbr_rules) == 0 : true
    error_message = "When passing a Hyper Protect Crypto Services (HPCS) instance as a value for `existing_kms_instance_crn` you cannot provide `cbr_rules`. Context-based restrictions are not supported by HPCS instances. For more information, go to [services that integrate with context-based restrictions](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#cbr-adopters)."
  }
}
