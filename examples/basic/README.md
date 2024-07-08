# Basic example

A basic example that shows how to provision a Key Protect instance, Key Ring, and Keys.

The following resources are provisioned by this example:
- A new resource group, if an existing one is not passed in.
- A Key Protect instance in the resource group and region provided.
- A new Key Ring with multiple new Keys in the newly provisioned Key Protect instance.
 - A context-based restriction (CBR) rule to only allow Key Protect to be accessible from Schematics. HPCS does not support context-based restriction (CBR). For more information, see https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#cbr-adopters for the services that supports CBR
