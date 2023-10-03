##############################################################################
# Common Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The name of the Resource Group to provision all resources in."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where all resources will be provisioned."
}

variable "create_key_protect_instance" {
  type        = bool
  description = "A flag to control whether a Key Protect instance is created, defaults to true."
  default     = true
}

variable "key_protect_instance_name" {
  type        = string
  description = "The name to give the Key Protect instance that will be provisioned by this module. Only used if 'create_key_protect_instance' is true"
  default     = null
}

variable "key_protect_plan" {
  type        = string
  description = "Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported. Only used if 'create_key_protect_instance' is true"
  default     = "tiered-pricing"

  validation {
    condition     = can(regex("^tiered-pricing$", var.key_protect_plan))
    error_message = "Currently the only supported value for plan is 'tiered-pricing'."
  }
}

variable "rotation_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a rotation policy on the Key Protect instance."
  default     = true
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive."
  default     = 1
}

variable "dual_auth_delete_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform."
  default     = false
}

variable "enable_metrics" {
  type        = bool
  description = "Set to true to enable metrics on the Key Protect instance (ignored is value for 'existing_key_protect_instance_guid' is passed). In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}

variable "key_create_import_access_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a key create import access policy on the instance"
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
  description = "Key create import access policy settings to configure if var.enable_key_create_import_access_policy is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess"
  default     = {}
}

variable "key_protect_endpoint_type" {
  type        = string
  description = "The type of the service endpoints to be set for the Key Protect instance. Possible values are 'public', 'private', or 'public-and-private'. Ignored is value for 'existing_key_protect_instance_guid' is passed."
  default     = "public-and-private"
  validation {
    condition     = can(regex("public|private|public-and-private", var.key_protect_endpoint_type))
    error_message = "The endpoint_type value must be 'public', 'private' or 'public-and-private'."
  }
}

variable "existing_key_protect_instance_guid" {
  type        = string
  description = "The GUID of an existing Key Protect instance, required if 'var.create_key_protect_instance' is false."
  default     = null
}

variable "key_map" {
  type        = map(list(string))
  description = "Use this variable if you wish to create both a new key ring and new key. The map should contain the desired Key Ring name as the keys of the map, and a list of desired Key Protect Key names to create as the values for each Key Ring."
  default     = {}
}

variable "existing_key_map" {
  type        = map(list(string))
  description = "Use this variable if you wish to create new keys inside already existing Key Ring(s). The map should contain the existing Key Ring name as the keys of the map, and a list of desired Key Protect Key names to create as the values for each existing Key Ring."
  default     = {}
}

variable "force_delete_key_ring" {
  type        = bool
  description = "Set to `true` to force delete key ring or `false` if not"
  default     = true
}

variable "force_delete" {
  type        = bool
  description = "Allow keys to be force deleted, even if key is in use"
  default     = true
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
  description = "A list of access tags to apply to the Key Protect instance created by the module."
  default     = []
}
