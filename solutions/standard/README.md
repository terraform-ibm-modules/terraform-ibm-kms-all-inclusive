# KMS standard solution

This solution supports the following:
- Creating a new resource group, or taking in an existing one.
- Provisioning of a Key Protect instance (private and public-and-private), or taking in an existing KMS instance (Key Protect or Hyper Protect Crypto Services).
- Creation of a KMS Key Rings and Keys.

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

## Known limitations
There is currently a known issue with the IBM provider (https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5154) where the provider is always trying to use the public endpoint when communicating with the Key Protect instance, even if the instance has public endpoint disabled. You will see an error like below on apply:
```
Error: [ERROR] Get Policies failed with error : kp.Error: correlation_id='1920e5b8-d5af-4b13-8e67-11872f43bc87', msg='Unauthorized: Either the user does not have access to the specified resource, the resource does not exist, or the region is incorrectly set'
```
As a workaround, you can set the following environment variable before running apply:
```
export IBMCLOUD_KP_API_ENDPOINT=https://private.REGION.kms.cloud.ibm.com
```
where `REGION` is the value you have set for the `region` input variable.

![key-protect](../../reference-architecture/key_protect.svg)
