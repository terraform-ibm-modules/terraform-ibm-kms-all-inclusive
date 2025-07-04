terraform {
  required_version = ">= 1.9.0"

  # Each required provider's version should be a flexible range to future proof the module's usage with upcoming minor and patch versions.
  required_providers {
    # ignore linter error - include providers required by all child modules
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.79.1, <2.0.0"
    }
  }
}
