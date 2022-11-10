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

variable "prefix" {
  type        = string
  description = "The prefix to use for naming all of the provisioned resources."
}

variable "enable_metrics" {
  type        = bool
  description = "Set as true to enable metrics on the Key Protect instance."
  default     = true
}

variable "key_protect_instance_name" {
  type        = string
  description = "The name of the existing Key Protect instance, if 'create_key_protect_instance' is true a new instance will be created with this name."
  default     = null
}

variable "create_key_protect_instance" {
  type        = bool
  description = "A flag to control whether a Key Protect instance is created, defaults to true."
  default     = true
}

variable "use_existing_key_rings" {
  type        = bool
  description = "A flag to control whether the 'existing_key_map' variable is used, defaults to false."
  default     = false
}

variable "key_map" {
  type        = map(list(string))
  description = "A Map containing the desired Key Ring Names as the keys of the map and a list of desired Key Protect Key names as the values for each Key Ring."
}

variable "existing_key_map" {
  type        = map(list(string))
  description = "A Map containing existing Key Ring names as the keys of the map and a list of desired Key Protect Key names as the values for each existing Key Ring, these keys will only be created if `create_key_protect_instance' is false."
  default     = {}
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources."
  default     = []
}
