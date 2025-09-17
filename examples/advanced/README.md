# Advanced private only instance with CBRs

An advanced example that shows how to provision a private only Key Protect instance with a new Key Ring and Key.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A CBR zone for the Schematics service.
 - A new Secrets Manager instance with private cert engine configured if one is not passed in.
 - A new Secrets Manager managed private certificate.
 - A new private Key Protect instance in the given resource group and region.
 - A new KMS key ring.
 - New KMS root keys and KMIP adapters using the Secrets Manager managed private certificate.
 - A context-based restriction (CBR) rule to only allow Key Protect to be accessible from Schematics zone.
