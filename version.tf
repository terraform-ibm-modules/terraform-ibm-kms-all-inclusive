terraform {
  required_version = ">= 1.0.0"

  # Use "greater than or equal to" range in modules
  required_providers {
    # ignore linter error - include providers required by all child modules
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.53.0"
    }
  }
}
