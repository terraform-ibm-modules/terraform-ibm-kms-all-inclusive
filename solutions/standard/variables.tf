########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "existing_resource_group" {
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

########################################################################################################################
# Key Protect instance variables
########################################################################################################################

variable "key_protect_instance_name" {
  type        = string
  default     = "base-security-services-kms"
  description = "The name to give the Key Protect instance that will be provisioned by this solution. Only used if not supplying an existing KMS instance."
}

variable "service_endpoints" {
  type        = string
  default     = "public-and-private" # TODO: Default this to private when https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5154 is fixed
  description = "The service endpoints to enable for the Key Protect instance deployed by this solution. Allowed values are `private` or `public-and-private`. If selecting `public-and-private`, communication to the instance will all be done over the public endpoints. Ensure to enable virtual routing and forwarding (VRF) in your account if using `private`, and that the terraform runtime has access to the the IBM Cloud private network."
  validation {
    condition     = contains(["private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values are `private` or `public-and-private`."
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

variable "existing_kms_guid" {
  type        = string
  default     = null
  description = "The GUID of an existing KMS instance to use. If not supplied, a new Key Protect instance will be created."
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
