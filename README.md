<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->
# Terraform Modules Template Project
<!-- UPDATE BADGE: Update the link for the following badge-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive/releases/latest)

This module 'glues' the different modules pertaining to Key Protect to create a full end-to-end key infrastructure. The following modules are used:
- [Key Protect Instance Module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect)
- [Key Module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key)
- [Key Ring Module](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key-ring)

This module takes a map `key_map` allowing to 'easily' create hierarchical key topology as follows, in a given Key Protect instance:

```
├── key-ring-1
│   ├── root-key-1
│   ├── root-key-2
│   ├── root-key-...
├── key-ring-2
│   ├── root-key-3
│   ├── root-key-4
│   ├── root-key-...
```

## Design intent

The intent is to facilitate creating key topologies grouping root keys per service type through the use of [key rings](https://cloud.ibm.com/docs/key-protect?topic=key-protect-grouping-keys).

Given that access is managed at the key ring level in Key Protect, this enables meeting least-privilege controls (NIST AC-6) while reducing the number of access groups to assign. Note that in the current version of this module, access controls are not assigned to key rings.

Example of typical topology per key protect instance:

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

with the strings `cos-bucket` and `ocp-cluster` being the cos/ocp cluster ids.


## Multiple Key Protect instances, and potential future directions for this module

As described above, this module creates or take one existing key protect instance, and creates the described key topology in that instance.

This module does NOT create multiple key protect instances. This may be a future addition depending on consumer needs.

However, note that in a typical production environment, services would typically need multiple key protect instance to achieve required isolation:
- At minimum, isolation between regulatory boundaries (eg: FedRamp, Rest of World)
- Isolation between keys used by service's control plane, and service's data plane (ICD services)

In the current version of the module, it is expected that the consumer would write logic (eg: in their scaffold) that invoke this module multiple times to create the corresponding key protect instances.

One simple pattern that is emerging, is to create one key protect instance per VPC. All workload in the VPC access the key protect instance via a VPE binding. This simple approach ensures there is actual network segmentation. A drawback is that this approach creates more key protect instances that necessary in some case.



## Usage

```hcl
##############################################################################
# Key Protect All Inclusive
##############################################################################

# Replace "main" with a GIT release version to lock into a specific release
module "key_protect_all_inclusive" {
    source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=main"
    resource_group_id = "1234qwerasdfzxcv5678tyuighjk" #pragma: allowlist secret
    region            = "us-south"
    prefix            = "kp-all-inclusive"
    key_map           = {
        "example-key-ring-1" = ["example-key-1", "example-key-2"]
        "example-key-ring-2" = ["example-key-3", "example-key-4"]
    }
}
```

### Note:
The RestAPI provider configuration that is needed for enabling metrics in the key-protect-module needs to be configured with specific headers that differ from other modules in GoldenEye, please use a configuration containing the following headers. You may need to set this provider as an alias if using other modules which require the RestAPI provider
```
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.key_protect_all_inclusive.key_protect_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
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

<!-- END MODULE HOOK -->
<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ End to end example with default values](examples/default)
- [ Existing resources example](examples/existing-resources)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.45.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >= 1.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_key_ring_keys"></a> [existing\_key\_ring\_keys](#module\_existing\_key\_ring\_keys) | git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git | v1.0.0 |
| <a name="module_key_protect"></a> [key\_protect](#module\_key\_protect) | git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect.git | v1.0.0 |
| <a name="module_key_protect_key_rings"></a> [key\_protect\_key\_rings](#module\_key\_protect\_key\_rings) | git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key-ring.git | v1.0.0 |
| <a name="module_key_protect_keys"></a> [key\_protect\_keys](#module\_key\_protect\_keys) | git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-key.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_kms_key_rings.existing_key_rings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/kms_key_rings) | data source |
| [ibm_resource_instance.existing_key_protect](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_key_protect_instance"></a> [create\_key\_protect\_instance](#input\_create\_key\_protect\_instance) | A flag to control whether a Key Protect instance is created, defaults to true. | `bool` | `true` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Set as true to enable metrics on the Key Protect instance. | `bool` | `true` | no |
| <a name="input_existing_key_map"></a> [existing\_key\_map](#input\_existing\_key\_map) | A Map containing existing Key Ring names as the keys of the map and a list of desired Key Protect Key names as the values for each existing Key Ring, these keys will only be created if `create_key_protect_instance' is false.` | `map(list(string))` | `{}` | no |
| <a name="input_key_endpoint_type"></a> [key\_endpoint\_type](#input\_key\_endpoint\_type) | The type of endpoint to be used for keys, accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_key_map"></a> [key\_map](#input\_key\_map) | A Map containing the desired Key Ring Names as the keys of the map and a list of desired Key Protect Key names as the values for each Key Ring. | `map(list(string))` | n/a | yes |
| <a name="input_key_protect_endpoint_type"></a> [key\_protect\_endpoint\_type](#input\_key\_protect\_endpoint\_type) | The type of endpoint to be used, if creating instances for keys and key rings, accepts 'public' or 'private' | `string` | `"public-and-private"` | no |
| <a name="input_key_protect_instance_name"></a> [key\_protect\_instance\_name](#input\_key\_protect\_instance\_name) | The name of the existing Key Protect instance, if 'create\_key\_protect\_instance' is true a new instance will be created with this name. | `string` | `null` | no |
| <a name="input_key_ring_endpoint_type"></a> [key\_ring\_endpoint\_type](#input\_key\_ring\_endpoint\_type) | The type of endpoint to be used, if creating instances for key rings, accepts 'public' or 'private' | `string` | `"public"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to use for naming all of the provisioned resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where all resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The name of the Resource Group to provision all resources in. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources. | `list(string)` | `[]` | no |
| <a name="input_use_existing_key_rings"></a> [use\_existing\_key\_rings](#input\_use\_existing\_key\_rings) | A flag to control whether the 'existing\_key\_map' variable is used, defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_existing_key_ring_keys"></a> [existing\_key\_ring\_keys](#output\_existing\_key\_ring\_keys) | IDs of Keys created by the module in existing Key Rings |
| <a name="output_key_protect_guid"></a> [key\_protect\_guid](#output\_key\_protect\_guid) | Key Protect GUID |
| <a name="output_key_rings"></a> [key\_rings](#output\_key\_rings) | IDs of Key Rings created by the module |
| <a name="output_keys"></a> [keys](#output\_keys) | IDs of Keys created by the module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
