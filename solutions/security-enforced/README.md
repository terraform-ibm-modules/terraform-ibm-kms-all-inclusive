# KMS security enforced solution

This solution supports the following:
- Provisioning of a Key Protect instance (private only) in an existing resource group, or taking in an existing KMS instance (Key Protect or Hyper Protect Crypto Services).
- Creation of a KMS Key Rings and Keys inside the KMS instance.

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

![key-protect](../../reference-architecture/key_protect.svg)
