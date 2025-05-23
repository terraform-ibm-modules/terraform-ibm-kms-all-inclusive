variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "kp-adv-all-inc"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Key Protect instance created by the module."
  default     = []
}

variable "existing_secrets_manager_crn" {
  type        = string
  description = "CRN of an existing Secrets Manager instance"
  default     = null
}

variable "existing_cert_template_name" {
  type        = string
  description = "Name of an existing Private Certificate template to use, required if providing a value for `existing_secrets_manager_crn`"
  default     = null
}
