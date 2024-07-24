variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region in which existing KMS instance exists"
  default     = "us-south"
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "CRN of an existing KMS instance"
}
