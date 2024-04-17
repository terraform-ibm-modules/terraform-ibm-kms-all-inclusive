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
  description = "The name of a new or an existing resource group in which to provision KMS resources to."
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "The region in which to provision KMS resources. If using existing KMS, set this to the region in which it is provisioned in."
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
  description = "The name to give the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing KMS instance. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value"
}

variable "key_protect_allowed_network" {
  type        = string
  description = "The type of the allowed network to be set for the Key Protect instance. Possible values are 'private-only', or 'public-and-private'. Only used if not supplying an existing KMS instance."
  default     = "private-only"
  validation {
    condition     = can(regex("private-only|public-and-private", var.key_protect_allowed_network))
    error_message = "The key_protect_allowed_network value must be 'private-only' or 'public-and-private'."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the Key Protect instance. Only used if not supplying an existing KMS instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to apply to the Key Protect instance. Only used if not supplying an existing KMS instance."
  default     = []
}

########################################################################################################################
# Existing KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existed Hyper Protect Crypto Services or Key Protect instance. If not supplied, a new Key Protect instance will be created."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for creating keys and key rings in the existing KMS instance. Accepts 'public' or 'private', defaults to 'private'.  Only used when supplying an existing KMS instance."
  default     = "private"
  # validation is performed in root module
}

########################################################################################################################
# Key Ring / Key variables
########################################################################################################################

variable "keys" {
  type = list(object({
    key_ring_name         = string
    existing_key_ring     = optional(bool, false)
    force_delete_key_ring = optional(bool, true)
    keys = list(object({
      key_name                 = string
      standard_key             = optional(bool, false)
      rotation_interval_month  = optional(number, 1)
      dual_auth_delete_enabled = optional(bool, false)
      force_delete             = optional(bool, true)
    }))
  }))
  description = "A list of objects which contain the key ring name, a flag indicating if this key ring already exists, and a flag to enable force deletion of the key ring. In addition, this object contains a list of keys with all of the information on the keys to be created in that key ring."
  default     = []
}
