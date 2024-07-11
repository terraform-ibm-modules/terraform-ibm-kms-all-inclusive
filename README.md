> TEST: SAMPLE CHANGES TO ENSURE TEST SHOULD RUN WHEN A PR IS CREATED - validation of an issue.
# KMS all inclusive module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-kms-all-inclusive?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module combines the following key management service (KMS) modules to create a full end-to-end key infrastructure:

- [Key Protect module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect)
- [KMS Key module](https://github.com/terraform-ibm-modules/terraform-ibm-kms-key)
- [KMS Key Ring module](https://github.com/terraform-ibm-modules/terraform-ibm-kms-key-ring)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-kms-all-inclusive](#terraform-ibm-kms-all-inclusive)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Existing KMS example](./examples/existing-resources)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## Reference architectures
- [KMS standard solution](https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/solutions/standard)

## terraform-ibm-kms-all-inclusive

The module takes a list, called `keys`, that supports hierarchical "key rings" for a single key management service (KMS) instance. Because access to key rings is managed in the KMS, you can comply with controls around least privilege (for example, [NIST AC-6](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#/control?version=4.0&number=AC-6)) and can reduce the number of access groups you need to assign. For more information about key rings, see [Grouping keys together using key rings](https://cloud.ibm.com/docs/key-protect?topic=key-protect-grouping-keys).
The following example shows a typical topology for a KMS instance:

```md
├── cos-key-ring
│   ├── root-key-cos-bucket-1
│   ├── root-key-cos-bucket-2
│   ├── root-key-cos-bucket-...
├── ocp-key-ring
│   ├── root-key-ocp-cluster-1
│   ├── root-key-ocp-cluster-2
│   ├── root-key-ocp-cluster-...
```

In this scenario `cos` and `ocp` represent different IBM Cloud Services that utilize KMS keys to encrypt data at rest, each of the keys represent a different bucket or cluster in your environment.

### Using HPCS instead of Key Protect

This module supports creating key rings and keys for Key Protect or Hyper Protect Crypto Services (HPCS). By default the module creates a Key Protect instance and creates the key rings and keys in that service instance, but this can be modified to use an existing HPCS instance by providing the GUID of your HPCS instance in the `var.existing_kms_instance_guid` input variable, and then setting the `var.create_key_protect_instance` input variable to `false`. For more information on provisioning an HPCS instance, please see: <https://github.com/terraform-ibm-modules/terraform-ibm-hpcs>

### Using Multiple Key Protect instances

The module supports only a single KMS instance and creates the key topology in that instance. The module code doesn't create multiple Key Protect instances, or support key rings and keys across multiple KMS instances.

In a typical production environment, services might need multiple Key Protect or HPCS instances for compliance reasons. For example, you might need isolation between regulatory boundaries (for example, between FedRamp and everything else). Or you might be required to isolate keys that are used by a service's control plane from the data plane (for example, with IBM Cloud Databases (ICD) services).

To achieve compliance, you can write logic to call the module multiple times for multiple KMS instances.

One emerging pattern is to use one KMS instance per VPC. All workloads in the VPC access the KMS instance through a VPE binding. This simple approach ensures network segmentation. A drawback is that this approach creates more KMS instances than necessary, in some case.


### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "kms_all_inclusive" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "X.X.X" # replace "X.X.X" with a release version to lock into a specific release
  key_protect_instance_name = "my-key-protect-instance"
  resource_group_id         = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                    = "us-south"
  keys = [
    # use an existing key ring named "example-key-ring-1"
    {
      key_ring_name = "example-key-ring-1"
      existing_key_ring = true
      force_delete_key_ring = false
      keys = [
        {
          key_name = "example-key-1"
          standard_key = true
          rotation_interval_month = 1
          dual_auth_delete_enabled = true
          force_delete = true
        },
        {
          key_name = "example-key-2"
          standard_key = false
          rotation_interval_month = 12
          dual_auth_delete enabled = false
          force_delete = false
        }
      ]
    },
    # create a new key ring named "example-key-ring-2"
    {
      key_ring_name = "example-key-ring-2"
      existing_key_ring = false
      force_delete_key_ring = true
      keys = [
        {
          key_name = "example-key-3"
          standard_key = true
          rotation_interval_month = 4
          dual_auth_delete_enabled = true
          force_delete = true
        },
        {
          key_name = "example-key-4"
          standard_key = false
          rotation_interval_month = 8
          dual_auth_delete enabled = false
          force_delete = false
        }
      ]
    }
  ]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Key Protect** service
        - `Editor` platform access
        - `Manager` service access

For more info, see [Understanding user roles and resources](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-access)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.65.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_key_ring_keys"></a> [existing\_key\_ring\_keys](#module\_existing\_key\_ring\_keys) | terraform-ibm-modules/kms-key/ibm | v1.2.4 |
| <a name="module_key_protect"></a> [key\_protect](#module\_key\_protect) | terraform-ibm-modules/key-protect/ibm | 2.7.2 |
| <a name="module_kms_key_rings"></a> [kms\_key\_rings](#module\_kms\_key\_rings) | terraform-ibm-modules/kms-key-ring/ibm | v2.4.1 |
| <a name="module_kms_keys"></a> [kms\_keys](#module\_kms\_keys) | terraform-ibm-modules/kms-key/ibm | v1.2.4 |

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.existing_kms_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Key Protect instance created by the module. Only used if 'create\_key\_protect\_instance' is true. | `list(string)` | `[]` | no |
| <a name="input_create_key_protect_instance"></a> [create\_key\_protect\_instance](#input\_create\_key\_protect\_instance) | A flag to control whether a Key Protect instance is created, defaults to true. | `bool` | `true` | no |
| <a name="input_dual_auth_delete_enabled"></a> [dual\_auth\_delete\_enabled](#input\_dual\_auth\_delete\_enabled) | If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform. Only used if 'create\_key\_protect\_instance' is true. | `bool` | `false` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Set to true to enable metrics on the Key Protect instance. Only used if 'create\_key\_protect\_instance' is true. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics. | `bool` | `true` | no |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of an existing Key Protect or Hyper Protect Crypto Services instance. Required if 'create\_key\_protect\_instance' is false. | `string` | `null` | no |
| <a name="input_key_create_import_access_enabled"></a> [key\_create\_import\_access\_enabled](#input\_key\_create\_import\_access\_enabled) | If set to true, Key Protect enables a key create import access policy on the instance. Only used if 'create\_key\_protect\_instance' is true. | `bool` | `true` | no |
| <a name="input_key_create_import_access_settings"></a> [key\_create\_import\_access\_settings](#input\_key\_create\_import\_access\_settings) | Key create import access policy settings to configure if 'enable\_key\_create\_import\_access\_policy' is true. Only used if 'create\_key\_protect\_instance' is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess | <pre>object({<br>    create_root_key     = optional(bool, true)<br>    create_standard_key = optional(bool, true)<br>    import_root_key     = optional(bool, true)<br>    import_standard_key = optional(bool, true)<br>    enforce_token       = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_key_endpoint_type"></a> [key\_endpoint\_type](#input\_key\_endpoint\_type) | The type of endpoint to be used for creating keys. Accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_key_protect_allowed_network"></a> [key\_protect\_allowed\_network](#input\_key\_protect\_allowed\_network) | The type of the allowed network to be set for the Key Protect instance. Possible values are 'private-only', or 'public-and-private'. Only used if 'create\_key\_protect\_instance' is true. | `string` | `"public-and-private"` | no |
| <a name="input_key_protect_instance_name"></a> [key\_protect\_instance\_name](#input\_key\_protect\_instance\_name) | The name to give the Key Protect instance that will be provisioned by this module. Only used if 'create\_key\_protect\_instance' is true. | `string` | `"key-protect"` | no |
| <a name="input_key_protect_plan"></a> [key\_protect\_plan](#input\_key\_protect\_plan) | Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported. Only used if 'create\_key\_protect\_instance' is true. | `string` | `"tiered-pricing"` | no |
| <a name="input_key_ring_endpoint_type"></a> [key\_ring\_endpoint\_type](#input\_key\_ring\_endpoint\_type) | The type of endpoint to be used for creating key rings. Accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | A list of objects which contain the key ring name, a flag indicating if this key ring already exists, and a flag to enable force deletion of the key ring. In addition, this object contains a list of keys with all of the information on the keys to be created in that key ring. | <pre>list(object({<br>    key_ring_name         = string<br>    existing_key_ring     = optional(bool, false)<br>    force_delete_key_ring = optional(bool, false)<br>    keys = list(object({<br>      key_name                 = string<br>      standard_key             = optional(bool, false)<br>      rotation_interval_month  = optional(number, 1)<br>      dual_auth_delete_enabled = optional(bool, false)<br>      force_delete             = optional(bool, false)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where all resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the Resource Group to provision the Key Protect instance in. Not required if 'create\_key\_protect\_instance' is false. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to the Key Protect instance. Only used if 'create\_key\_protect\_instance' is true. | `list(string)` | `[]` | no |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | If set to true, Key Protect enables a rotation policy on the Key Protect instance. Only used if 'create\_key\_protect\_instance' is true. | `bool` | `true` | no |
| <a name="input_rotation_interval_month"></a> [rotation\_interval\_month](#input\_rotation\_interval\_month) | Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive. Only used if 'create\_key\_protect\_instance' is true. | `number` | `1` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_protect_crn"></a> [key\_protect\_crn](#output\_key\_protect\_crn) | Key Protect service instance CRN when an instance is created, otherwise null |
| <a name="output_key_protect_id"></a> [key\_protect\_id](#output\_key\_protect\_id) | Key Protect service instance ID when an instance is created, otherwise null |
| <a name="output_key_protect_instance_policies"></a> [key\_protect\_instance\_policies](#output\_key\_protect\_instance\_policies) | Instance Polices of the Key Protect instance |
| <a name="output_key_protect_name"></a> [key\_protect\_name](#output\_key\_protect\_name) | Key Protect Name |
| <a name="output_key_rings"></a> [key\_rings](#output\_key\_rings) | IDs of new Key Rings created by the module |
| <a name="output_keys"></a> [keys](#output\_keys) | IDs of new Keys created by the module |
| <a name="output_kms_guid"></a> [kms\_guid](#output\_kms\_guid) | KMS GUID |
| <a name="output_kms_private_endpoint"></a> [kms\_private\_endpoint](#output\_kms\_private\_endpoint) | Key Management Service instance private endpoint URL |
| <a name="output_kms_public_endpoint"></a> [kms\_public\_endpoint](#output\_kms\_public\_endpoint) | Key Management Service instance public endpoint URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
