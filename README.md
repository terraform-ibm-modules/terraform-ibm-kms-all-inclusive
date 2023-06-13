# Key Protect all inclusive module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module combines the following Key Protect modules to create a full end-to-end key infrastructure:
- [Key Protect module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect)
- [Key Protect key module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key)
- [Key Protect key ring module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key-ring)

The module takes a map, called `key_map`, that supports hierarchical "key rings" for a single Key Protect instance. Because access to key rings is managed in Key Protect, you can comply with controls around least privilege (for example, [NIST AC-6](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#/control?version=4.0&number=AC-6)) and can reduce the number of access groups you need to assign. For more information about key rings, see [Grouping keys together using key rings](https://cloud.ibm.com/docs/key-protect?topic=key-protect-grouping-keys).
The following example shows a typical topology for a Key Protect instance:
```
├── cos-key-ring
│   ├── root-key-cos-bucket-1
│   ├── root-key-cos-bucket-2
│   ├── root-key-cos-bucket-...
├── ocp-key-ring
│   ├── root-key-ocp-cluster-1
│   ├── root-key-ocp-cluster-2
│   ├── root-key-ocp-cluster-...
```

## Multiple Key Protect instances, and potential future directions for this module
The strings `cos-bucket` and `ocp-cluster` are the cluster IDs for Cloud Object Storage and for the OpenShift Container Platform.

The module supports only a single Key Protect instance and creates the key topology in that instance. It doesn't create multiple Key Protect instances. However, in a typical production environment, services might need multiple Key Protect instances for compliance reasons.

For example, you might need isolation between regulatory boundaries (for example, between FedRamp and everything else). Or you might be required to isolate keys that are used by a service's control plane from the data plane (for example, with IBM Cloud Databases (ICD) services).

To achieve compliance, you can write logic to call the module multiple times to create multiple Key Protect instances.

One emerging pattern is to create one Key Protect instance per VPC. All workloads in the VPC access the Key Protect instance through a VPE binding. This simple approach ensures network segmentation. A drawback is that this approach creates more Key Protect instances than necessary, in some case.


## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "key_protect_all_inclusive" {
  source  = "terraform-ibm-modules/key-protect-all-inclusive/ibm"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  key_protect_instance_name = "my-key-protect-instance"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region            = "us-south"
  key_map           = {
    "example-key-ring-1" = ["example-key-1", "example-key-2"]
    "example-key-ring-2" = ["example-key-3", "example-key-4"]
  }
}
```

## Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Key Protect** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ End to end example with default values](examples/default)
- [ Existing resources example](examples/existing-resources)
- [ Example with SLZ default values](examples/slz)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_key_ring_keys"></a> [existing\_key\_ring\_keys](#module\_existing\_key\_ring\_keys) | terraform-ibm-modules/key-protect/ibm | 2.2.0 |
| <a name="module_key_protect"></a> [key\_protect](#module\_key\_protect) | terraform-ibm-modules/key-protect/ibm | 2.2.0 |
| <a name="module_key_protect_key_rings"></a> [key\_protect\_key\_rings](#module\_key\_protect\_key\_rings) | terraform-ibm-modules/key-protect-key-ring/ibm | 2.0.1 |
| <a name="module_key_protect_keys"></a> [key\_protect\_keys](#module\_key\_protect\_keys) | terraform-ibm-modules/key-protect/ibm | 2.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Key Protect instance created by the module. | `list(string)` | `[]` | no |
| <a name="input_create_key_protect_instance"></a> [create\_key\_protect\_instance](#input\_create\_key\_protect\_instance) | A flag to control whether a Key Protect instance is created, defaults to true. | `bool` | `true` | no |
| <a name="input_dual_auth_delete_enabled"></a> [dual\_auth\_delete\_enabled](#input\_dual\_auth\_delete\_enabled) | If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform. | `bool` | `false` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Set to true to enable metrics on the Key Protect instance (ignored is value for 'existing\_key\_protect\_instance\_guid' is passed). In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics. | `bool` | `true` | no |
| <a name="input_existing_key_map"></a> [existing\_key\_map](#input\_existing\_key\_map) | Use this variable if you wish to create new keys inside already existing Key Ring(s). The map should contain the existing Key Ring name as the keys of the map, and a list of desired Key Protect Key names to create as the values for each existing Key Ring. | `map(list(string))` | `{}` | no |
| <a name="input_existing_key_protect_instance_guid"></a> [existing\_key\_protect\_instance\_guid](#input\_existing\_key\_protect\_instance\_guid) | The GUID of an existing Key Protect instance, required if 'var.create\_key\_protect\_instance' is false. | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Allow keys to be force deleted, even if key is in use | `bool` | `true` | no |
| <a name="input_key_create_import_access_enabled"></a> [key\_create\_import\_access\_enabled](#input\_key\_create\_import\_access\_enabled) | If set to true, Key Protect enables a key create import access policy on the instance | `bool` | `true` | no |
| <a name="input_key_create_import_access_settings"></a> [key\_create\_import\_access\_settings](#input\_key\_create\_import\_access\_settings) | Key create import access policy settings to configure if var.enable\_key\_create\_import\_access\_policy is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess | <pre>object({<br>    create_root_key     = optional(bool, true)<br>    create_standard_key = optional(bool, true)<br>    import_root_key     = optional(bool, true)<br>    import_standard_key = optional(bool, true)<br>    enforce_token       = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_key_endpoint_type"></a> [key\_endpoint\_type](#input\_key\_endpoint\_type) | The type of endpoint to be used for creating keys. Accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_key_map"></a> [key\_map](#input\_key\_map) | Use this variable if you wish to create both a new key ring and new key. The map should contain the desired Key Ring name as the keys of the map, and a list of desired Key Protect Key names to create as the values for each Key Ring. | `map(list(string))` | `{}` | no |
| <a name="input_key_protect_endpoint_type"></a> [key\_protect\_endpoint\_type](#input\_key\_protect\_endpoint\_type) | The type of the service endpoints to be set for the Key Protect instance. Possible values are 'public', 'private', or 'public-and-private'. Ignored is value for 'existing\_key\_protect\_instance\_guid' is passed. | `string` | `"public-and-private"` | no |
| <a name="input_key_protect_instance_name"></a> [key\_protect\_instance\_name](#input\_key\_protect\_instance\_name) | The name to give the Key Protect instance that will be provisioned by this module. Only used if 'create\_key\_protect\_instance' is true | `string` | `null` | no |
| <a name="input_key_protect_plan"></a> [key\_protect\_plan](#input\_key\_protect\_plan) | Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported. Only used if 'create\_key\_protect\_instance' is true | `string` | `"tiered-pricing"` | no |
| <a name="input_key_ring_endpoint_type"></a> [key\_ring\_endpoint\_type](#input\_key\_ring\_endpoint\_type) | The type of endpoint to be used for creating key rings. Accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where all resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The name of the Resource Group to provision all resources in. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to the Key Protect instance. Only used if 'create\_key\_protect\_instance' is true. | `list(string)` | `[]` | no |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | If set to true, Key Protect enables a rotation policy on the Key Protect instance. | `bool` | `true` | no |
| <a name="input_rotation_interval_month"></a> [rotation\_interval\_month](#input\_rotation\_interval\_month) | Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_existing_key_ring_keys"></a> [existing\_key\_ring\_keys](#output\_existing\_key\_ring\_keys) | IDs of Keys created by the module in existing Key Rings |
| <a name="output_key_protect_guid"></a> [key\_protect\_guid](#output\_key\_protect\_guid) | Key Protect GUID |
| <a name="output_key_protect_id"></a> [key\_protect\_id](#output\_key\_protect\_id) | Key Protect service instance ID when an instance is created, otherwise null |
| <a name="output_key_protect_instance_policies"></a> [key\_protect\_instance\_policies](#output\_key\_protect\_instance\_policies) | Instance Polices of the Key Protect instance |
| <a name="output_key_protect_name"></a> [key\_protect\_name](#output\_key\_protect\_name) | Key Protect Name |
| <a name="output_key_rings"></a> [key\_rings](#output\_key\_rings) | IDs of new Key Rings created by the module |
| <a name="output_keys"></a> [keys](#output\_keys) | IDs of new Keys created by the module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
