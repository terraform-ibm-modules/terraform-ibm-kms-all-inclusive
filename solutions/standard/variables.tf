########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision key management resources to. If a prefix input variable is specified, it's added to the value in the `<prefix>-value` format."
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "The region in which to provision key management resources. If using an existing Key Protect or Hyper Protect Crypto Services instance, set this to the region where it was provisioned."
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to append to all resources created by this solution."
  default     = null
}

########################################################################################################################
# Key Protect instance variables
########################################################################################################################

variable "key_protect_instance_name" {
  type        = string
  default     = "base-security-services-kms"
  description = "The name to give the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance. If a prefix input variable is specified, it's added to the value in the `<prefix>-value` format."
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

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the Key Protect instance. Only used if not supplying an existing Key Protect or Hyper Protect Crypto Services instance."
  default     = []
}

variable "access_tags" {
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
  description = "The CRN of the existed Hyper Protect Crypto Services or Key Protect instance. If not supplied, a new instance will be created."
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
    }))
  }))
  description = "A list of key ring objects each containing one or more key objects. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/solutions/standard/DA-keys.md)."
  default     = []
}
